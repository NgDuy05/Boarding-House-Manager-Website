package Controllers;

import DALs.BillDAO;
import DALs.PaymentDAO;
import Models.Bill;
import Models.PaymentTransaction;
import Models.User;
import VnPay.VNPayService;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Map;

public class PaymentServlet extends HttpServlet {

    // ==============================
    // POST: action=pay — initiate VNPay payment
    // ==============================
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if ("pay".equals(action)) {
            handlePay(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
        }
    }

    // ==============================
    // GET: action=vnpay-return — handle VNPay callback
    // ==============================
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if ("vnpay-return".equals(action)) {
            handleVnpayReturn(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
        }
    }

    // ==============================
    // HANDLE PAY
    // ==============================
    private void handlePay(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String billIdParam = request.getParameter("billId");
        if (billIdParam == null || billIdParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/bill?action=mybill");
            return;
        }

        int billId;
        try {
            billId = Integer.parseInt(billIdParam);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/bill?action=mybill");
            return;
        }

        BillDAO billDAO = new BillDAO();
        Bill bill = billDAO.getBillById(billId);

        // Security: bill must exist and be pending
        if (bill == null || !"pending".equals(bill.getStatus())) {
            response.sendRedirect(request.getContextPath() + "/bill?action=mybill");
            return;
        }

        String vnpTxnRef = VNPayService.generateTxnRef();
        BigDecimal amount = bill.getTotalAmount();

        // Persist pending transaction
        PaymentTransaction pt = new PaymentTransaction();
        pt.setBillId(billId);
        pt.setVnpTxnRef(vnpTxnRef);
        pt.setAmount(amount);
        pt.setStatus("pending");

        PaymentDAO paymentDAO = new PaymentDAO();
        paymentDAO.insert(pt);

        // Build return URL dynamically from current request (port/context-path agnostic)
        String baseUrl = request.getScheme() + "://" + request.getServerName()
                + ":" + request.getServerPort() + request.getContextPath();
        String returnUrl = baseUrl + "/payment?action=vnpay-return";
        String orderInfo = "Thanh toan hoa don #" + billId;
        String ipAddress = VNPayService.getIpAddress(request);

        String paymentUrl = VNPayService.createPaymentUrl(
                baseUrl, vnpTxnRef, amount.longValue(), orderInfo, ipAddress, returnUrl);

        response.sendRedirect(paymentUrl);
    }

    // ==============================
    // HANDLE VNPAY RETURN
    // ==============================
    private void handleVnpayReturn(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Collect only vnp_* params — exclude our own "action" param which VNPay did not sign
        Map<String, String> params = new HashMap<>();
        Enumeration<String> paramNames = request.getParameterNames();
        while (paramNames.hasMoreElements()) {
            String name = paramNames.nextElement();
            if (name.startsWith("vnp_")) {
                params.put(name, request.getParameter(name));
            }
        }

        // Verify signature
        if (!VNPayService.verifySignature(params)) {
            request.setAttribute("paymentSuccess", false);
            request.setAttribute("errorMessage", "Invalid payment signature.");
            request.getRequestDispatcher("/views/customer/paymentResult.jsp").forward(request, response);
            return;
        }

        String vnpTxnRef    = params.get("vnp_TxnRef");
        String responseCode = params.get("vnp_ResponseCode");
        String bankCode     = params.get("vnp_BankCode");
        String transactionNo = params.get("vnp_TransactionNo");

        // Build raw gateway response string
        StringBuilder sb = new StringBuilder("{");
        for (Map.Entry<String, String> entry : params.entrySet()) {
            sb.append("\"").append(entry.getKey()).append("\":\"")
              .append(entry.getValue()).append("\",");
        }
        if (sb.charAt(sb.length() - 1) == ',') sb.deleteCharAt(sb.length() - 1);
        sb.append("}");
        String gatewayResponse = sb.toString();

        PaymentDAO paymentDAO = new PaymentDAO();
        PaymentTransaction pt = paymentDAO.getByTxnRef(vnpTxnRef);

        BillDAO billDAO = new BillDAO();
        Bill bill = null;

        if (pt != null) {
            bill = billDAO.getBillById(pt.getBillId());

            if (VNPayService.isPaymentSuccess(responseCode)) {
                paymentDAO.updateStatus(vnpTxnRef, "success", responseCode, bankCode, transactionNo, gatewayResponse);
                billDAO.updateStatus(pt.getBillId(), "paid");
                if (bill != null) bill.setStatus("paid");
                request.setAttribute("paymentSuccess", true);
            } else {
                paymentDAO.updateStatus(vnpTxnRef, "failed", responseCode, bankCode, transactionNo, gatewayResponse);
                request.setAttribute("paymentSuccess", false);
            }
        } else {
            request.setAttribute("paymentSuccess", false);
        }

        request.setAttribute("bill", bill);
        request.getRequestDispatcher("/views/customer/paymentResult.jsp").forward(request, response);
    }
}
