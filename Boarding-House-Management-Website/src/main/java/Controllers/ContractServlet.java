package Controllers;

import DALs.BillDAO;
import DALs.ContractDAO;
import DALs.DepositDAO;
import DALs.FacilityDAO;
import DALs.PriceDAO;
import DALs.RoomDAO;
import DALs.ServiceDAO;
import DALs.UtilityDAO;
import DALs.UserDAO;
import Models.Bill;
import Models.BillItem;
import Models.Contract;
import Models.ContractTenant;
import Models.ContractUser;
import Models.DepositTransaction;
import Models.Facility;
import Models.Room;
import Models.ServiceUsage;
import Models.User;
import Models.UtilityUsage;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.HashMap;
import java.util.Map;

public class ContractServlet extends HttpServlet {

    private ContractDAO contractDAO;
    private RoomDAO     roomDAO;
    private UserDAO     userDAO;
    private BillDAO     billDAO;
    private FacilityDAO facilityDAO;
    private DepositDAO  depositDAO;
    private UtilityDAO  utilityDAO;
    private ServiceDAO  serviceDAO;
    private PriceDAO    priceDAO;

    private static final int PAGE_SIZE = 10;

    @Override
    public void init() {
        contractDAO = new ContractDAO();
        roomDAO     = new RoomDAO();
        userDAO     = new UserDAO();
        billDAO     = new BillDAO();
        facilityDAO = new FacilityDAO();
        depositDAO  = new DepositDAO();
        utilityDAO  = new UtilityDAO();
        serviceDAO  = new ServiceDAO();
        priceDAO    = new PriceDAO();
    }

    // =====================================================================
    // GET
    // =====================================================================
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if (action == null) {
            action = isAdminOrStaff(request) ? "list" : "mycontract";
        }

        switch (action) {

            // ── ADMIN ──────────────────────────────────────────────────────
            case "list":
                listContracts(request, response);
                break;
            case "create":
                showCreateForm(request, response);
                break;
            case "edit":
                showEditForm(request, response);
                break;
            case "detail":
                showDetail(request, response);
                break;
            case "terminate":
                terminateContract(request, response);
                break;
            case "delete":
                deleteContract(request, response);
                break;
            case "approve":
                approveContract(request, response);
                break;
            case "reject":
                rejectContract(request, response);
                break;
            case "approveCancellation":
                approveCancellation(request, response);
                break;
            case "rejectCancellation":
                rejectCancellation(request, response);
                break;
            case "addTenant":
                showAddTenantForm(request, response);
                break;
            case "removeTenant":
                removeTenant(request, response);
                break;

            // ── CONTRACT_TENANT (non-account tenants) ──────────────────────
            case "addContractTenant":
                showAddContractTenantForm(request, response);
                break;
            case "editContractTenant":
                showEditContractTenantForm(request, response);
                break;
            case "removeContractTenant":
                removeContractTenant(request, response);
                break;

            // ── CUSTOMER ──────────────────────────────────────────────────
            case "mycontract":
                myContracts(request, response);
                break;
            case "mydetail":
                myContractDetail(request, response);
                break;
            case "signContract":
                showSignContractForm(request, response);
                break;
            case "getUserInfo":
                getUserInfo(request, response);
                break;
            case "requestCancellation":
                requestCancellation(request, response);
                break;

            default:
                response.sendRedirect(request.getContextPath() + "/contract?action=list");
        }
    }

    // =====================================================================
    // POST
    // =====================================================================
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if (action == null) action = "";

        switch (action) {
            case "insert":
                insertContract(request, response);
                break;
            case "customerSign":
                customerSignContract(request, response);
                break;
            case "requestCancellation":
                requestCancellation(request, response);
                break;
            case "update":
                updateContract(request, response);
                break;
            case "addTenant":
                addTenant(request, response);
                break;
            // ── CONTRACT_TENANT (non-account tenants) ──────────────────────
            case "saveContractTenant":
                saveContractTenant(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/contract?action=list");
        }
    }

    // =====================================================================
    // ADMIN – LIST
    // =====================================================================
    private void listContracts(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isAdminOrStaff(request)) { redirect401(request, response); return; }

        String statusFilter = request.getParameter("status");
        String search       = request.getParameter("search");

        List<Contract> all = contractDAO.getAllWithDetails(statusFilter, search);

        // stats
        long activeCount     = all.stream().filter(c -> "active".equals(c.getStatus())).count();
        long pendingCount    = all.stream().filter(c -> "pending".equals(c.getStatus())).count();
        long terminatedCount = all.stream().filter(c -> "terminated".equals(c.getStatus())).count();
        int  cancellationCount = contractDAO.countCancellationRequested();

        // pagination
        int totalItems = all.size();
        int totalPages = Math.max(1, (int) Math.ceil((double) totalItems / PAGE_SIZE));
        int page = parsePage(request.getParameter("page"), totalPages);

        int from = (page - 1) * PAGE_SIZE;
        int to   = Math.min(from + PAGE_SIZE, totalItems);
        List<Contract> contracts = (from < totalItems) ? all.subList(from, to) : java.util.Collections.emptyList();

        request.setAttribute("contracts",       contracts);
        request.setAttribute("activeCount",     activeCount);
        request.setAttribute("pendingCount",    pendingCount);
        request.setAttribute("terminatedCount", terminatedCount);
        request.setAttribute("cancellationCount", cancellationCount);
        request.setAttribute("totalItems",      totalItems);
        request.setAttribute("totalPages",      totalPages);
        request.setAttribute("currentPage",     page);
        request.setAttribute("pageSize",        PAGE_SIZE);
        request.setAttribute("statusFilter",    statusFilter);
        request.setAttribute("search",          search);

        forward(request, response, "/views/admin/contracts/contracts.jsp");
    }

    // =====================================================================
    // ADMIN – CREATE
    // =====================================================================
    private void showCreateForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isAdminOrStaff(request)) { redirect401(request, response); return; }

        List<Room> availableRooms = roomDAO.getByStatus("available");
        List<User> customers      = userDAO.getAllCustomers(null, "active");
        List<Facility> facilities = facilityDAO.getAllFacilities();

        request.setAttribute("availableRooms",       availableRooms);
        request.setAttribute("customers",            customers);
        request.setAttribute("facilities",           facilities);
        request.setAttribute("activeContractUserIds", contractDAO.getActiveContractUserIds());
        forward(request, response, "/views/admin/contracts/createContract.jsp");
    }

    private void insertContract(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {
        if (!isAdminOrStaff(request)) { redirect401(request, response); return; }

        try {
            int        roomId    = Integer.parseInt(request.getParameter("roomId"));
            LocalDate  startDate = LocalDate.parse(request.getParameter("startDate"));
            String     endStr    = request.getParameter("endDate");
            LocalDate  endDate   = (endStr == null || endStr.isEmpty()) ? null : LocalDate.parse(endStr);
            BigDecimal deposit   = new BigDecimal(request.getParameter("deposit").replaceAll(",", ""));
            int        userId    = Integer.parseInt(request.getParameter("primaryUserId"));

            // Parse duration_months (default 12)
            int durationMonths = 12;
            String durStr = request.getParameter("durationMonths");
            if (durStr != null && !durStr.isBlank()) {
                try { durationMonths = Integer.parseInt(durStr); } catch (NumberFormatException ignored) {}
            }

            // Server-side phone validation
            String tenantPhone = request.getParameter("tenantPhone");
            if (!isValidPhone(tenantPhone)) {
                forwardBackToCreate(request, response, "Số điện thoại không hợp lệ (VD: 0912345678)");
                return;
            }

            Contract c = new Contract(0, roomId, startDate, endDate, deposit, "active", false);
            c.setDurationMonths(durationMonths);

            // Calculate monthly_rent = room base price + Σ(facility.monthly_price × qty)
            Room selectedRoom = roomDAO.getRoomById(roomId);
            BigDecimal monthlyRent = (selectedRoom != null && selectedRoom.getBasePrice() != null)
                    ? selectedRoom.getBasePrice()
                    : BigDecimal.ZERO;
            String[] facilityIdsForRent  = request.getParameterValues("facilityId");
            String[] facilityQtysForRent = request.getParameterValues("facilityQty");
            if (facilityIdsForRent != null) {
                for (int i = 0; i < facilityIdsForRent.length; i++) {
                    try {
                        int fid = Integer.parseInt(facilityIdsForRent[i]);
                        int qty = (facilityQtysForRent != null && i < facilityQtysForRent.length)
                                ? Math.max(1, Integer.parseInt(facilityQtysForRent[i])) : 1;
                        Facility fac = facilityDAO.getFacilityById(fid);
                        if (fac != null && fac.getMonthlyPrice() != null) {
                            monthlyRent = monthlyRent.add(fac.getMonthlyPrice().multiply(BigDecimal.valueOf(qty)));
                        }
                    } catch (NumberFormatException ignored) {}
                }
            }
            c.setMonthlyRent(monthlyRent);

            int newId = contractDAO.insertWithTenant(c, userId);

            // Check if user already has active contract (insertWithTenant returns -2)
            if (newId == -2) {
                forwardBackToCreate(request, response,
                    "This tenant already has an active contract. Please terminate their current contract first.");
                return;
            }

            // Also create a contract_tenant record from the form fields if provided
            String tenantName = request.getParameter("tenantName");
            if (newId > 0 && tenantName != null && !tenantName.trim().isEmpty()) {
                ContractTenant ct = new ContractTenant();
                ct.setContractId(newId);
                ct.setFullName(tenantName.trim());
                ct.setPhone(request.getParameter("tenantPhone"));
                ct.setCccd(request.getParameter("tenantCccd"));
                String bdStr = request.getParameter("tenantBirthDate");
                if (bdStr != null && !bdStr.isEmpty()) ct.setBirthDate(LocalDate.parse(bdStr));
                ct.setPrimary(true);
                contractDAO.addContractTenant(ct);
            }

            if (newId > 0) {
                // Save selected facilities to room_facility
                String[] facilityIds  = request.getParameterValues("facilityId");
                String[] facilityQtys = request.getParameterValues("facilityQty");
                if (facilityIds != null) {
                    facilityDAO.softDeleteRoomFacilities(roomId);
                    for (int i = 0; i < facilityIds.length; i++) {
                        try {
                            int fid = Integer.parseInt(facilityIds[i]);
                            int qty = (facilityQtys != null && i < facilityQtys.length)
                                    ? Math.max(1, Integer.parseInt(facilityQtys[i]))
                                    : 1;
                            facilityDAO.upsertRoomFacility(roomId, fid, qty);
                        } catch (NumberFormatException ignored) {}
                    }
                }

                flash(request, "contractSuccess", "Contract #" + newId + " created successfully!");
                response.sendRedirect(request.getContextPath() + "/contract?action=list");
            } else {
                // Insert failed — stay on create form, preserve input
                forwardBackToCreate(request, response, "Failed to create contract. Please try again.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            forwardBackToCreate(request, response, "Invalid input: " + e.getMessage());
        }
    }

    /** Re-load create form with error message and original request params preserved as attributes */
    private void forwardBackToCreate(HttpServletRequest request, HttpServletResponse response,
                                     String errorMsg) throws ServletException, IOException {
        request.setAttribute("contractError", errorMsg);
        // Re-populate dropdowns
        request.setAttribute("availableRooms",       roomDAO.getByStatus("available"));
        request.setAttribute("customers",            userDAO.getAllCustomers(null, "active"));
        request.setAttribute("facilities",           facilityDAO.getAllFacilities());
        request.setAttribute("activeContractUserIds", contractDAO.getActiveContractUserIds());
        // Preserve submitted values so JSP can re-select them
        request.setAttribute("formRoomId",           request.getParameter("roomId"));
        request.setAttribute("formUserId",           request.getParameter("primaryUserId"));
        request.setAttribute("formStartDate",        request.getParameter("startDate"));
        request.setAttribute("formEndDate",          request.getParameter("endDate"));
        request.setAttribute("formDeposit",          request.getParameter("deposit"));
        request.setAttribute("formDurationMonths",   request.getParameter("durationMonths"));
        request.setAttribute("formTenantName",       request.getParameter("tenantName"));
        request.setAttribute("formTenantPhone",      request.getParameter("tenantPhone"));
        request.setAttribute("formTenantCccd",       request.getParameter("tenantCccd"));
        request.setAttribute("formTenantBd",         request.getParameter("tenantBirthDate"));
        forward(request, response, "/views/admin/contracts/createContract.jsp");
    }

    // =====================================================================
    // CUSTOMER – SIGN CONTRACT (POST)
    // =====================================================================
    private void customerSignContract(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        User user = currentUser(request);
        if (user == null) { response.sendRedirect(request.getContextPath() + "/auth?action=login"); return; }

        // One active contract per person at a time
        if (contractDAO.hasActiveContract(user.getUserId())) {
            flash(request, "contractError",
                    "You already have an active contract. Please terminate your current contract before signing a new one.");
            response.sendRedirect(request.getContextPath() + "/contract?action=mycontract");
            return;
        }

        try {
            int        roomId    = Integer.parseInt(request.getParameter("roomId"));
            LocalDate  startDate = LocalDate.parse(request.getParameter("startDate"));
            String     endStr    = request.getParameter("endDate");
            LocalDate  endDate   = (endStr == null || endStr.isEmpty()) ? null : LocalDate.parse(endStr);
            BigDecimal deposit   = new BigDecimal(request.getParameter("deposit").replaceAll(",", ""));

            // Parse duration_months (default 12)
            int durationMonths = 12;
            String durStr = request.getParameter("durationMonths");
            if (durStr != null && !durStr.isBlank()) {
                try { durationMonths = Integer.parseInt(durStr); } catch (NumberFormatException ignored) {}
            }

            // --- Calculate monthly_rent from room base price + selected facilities ---
            Room selectedRoom = roomDAO.getRoomById(roomId);
            BigDecimal monthlyRent = (selectedRoom != null && selectedRoom.getBasePrice() != null)
                    ? selectedRoom.getBasePrice() : BigDecimal.ZERO;

            String[] facilityIds  = request.getParameterValues("facilityId");
            String[] facilityQtys = request.getParameterValues("facilityQty");
            if (facilityIds != null) {
                for (int i = 0; i < facilityIds.length; i++) {
                    try {
                        int fid = Integer.parseInt(facilityIds[i]);
                        int qty = (facilityQtys != null && i < facilityQtys.length)
                                ? Math.max(1, Integer.parseInt(facilityQtys[i])) : 1;
                        Facility fac = facilityDAO.getFacilityById(fid);
                        if (fac != null && fac.getMonthlyPrice() != null) {
                            monthlyRent = monthlyRent.add(fac.getMonthlyPrice().multiply(BigDecimal.valueOf(qty)));
                        }
                    } catch (NumberFormatException ignored) {}
                }
            }

            Contract c = new Contract(0, roomId, startDate, endDate, deposit, "pending", false);
            c.setDurationMonths(durationMonths);
            c.setMonthlyRent(monthlyRent);
            int newId = contractDAO.insertWithTenant(c, user.getUserId());

            if (newId > 0) {
                // Save selected facilities into room_facility table
                if (facilityIds != null) {
                    facilityDAO.softDeleteRoomFacilities(roomId);
                    for (int i = 0; i < facilityIds.length; i++) {
                        try {
                            int fid = Integer.parseInt(facilityIds[i]);
                            int qty = (facilityQtys != null && i < facilityQtys.length)
                                    ? Math.max(1, Integer.parseInt(facilityQtys[i])) : 1;
                            facilityDAO.upsertRoomFacility(roomId, fid, qty);
                        } catch (NumberFormatException ignored) {}
                    }
                    // Persist final monthly_rent (already set in contract via insertWithTenant)
                    contractDAO.updateMonthlyRent(newId, monthlyRent);
                }

                flash(request, "contractSuccess", "Contract signed! Your contract request #" + newId + " is pending approval.");
                response.sendRedirect(request.getContextPath() + "/contract?action=mydetail&id=" + newId);
            } else {
                flash(request, "contractError", "Could not sign contract. The room may no longer be available.");
                response.sendRedirect(request.getContextPath() + "/contract?action=signContract&roomId=" + roomId);
            }
        } catch (Exception e) {
            e.printStackTrace();
            flash(request, "contractError", "Invalid input: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/contract?action=signContract");
        }
    }

    // =====================================================================
    // ADMIN – EDIT
    // =====================================================================
    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isAdminOrStaff(request)) { redirect401(request, response); return; }

        int id = Integer.parseInt(request.getParameter("id"));
        Contract c = contractDAO.getDetailById(id);
        if (c == null) { response.sendRedirect(request.getContextPath() + "/contract?action=list"); return; }

        request.setAttribute("contract", c);
        forward(request, response, "/views/admin/contracts/editContract.jsp");
    }

    private void updateContract(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        if (!isAdminOrStaff(request)) { redirect401(request, response); return; }

        try {
            int        contractId = Integer.parseInt(request.getParameter("contractId"));
            int        roomId     = Integer.parseInt(request.getParameter("roomId"));
            LocalDate  startDate  = LocalDate.parse(request.getParameter("startDate"));
            String     endStr     = request.getParameter("endDate");
            LocalDate  endDate    = (endStr == null || endStr.isEmpty()) ? null : LocalDate.parse(endStr);
            BigDecimal deposit    = new BigDecimal(request.getParameter("deposit").replaceAll(",", ""));
            String     status     = request.getParameter("status");

            Contract c = new Contract(contractId, roomId, startDate, endDate, deposit, status, false);
            contractDAO.update(c);
            flash(request, "contractSuccess", "Contract updated successfully!");
        } catch (Exception e) {
            e.printStackTrace();
            flash(request, "contractError", "Update failed: " + e.getMessage());
        }
        response.sendRedirect(request.getContextPath() + "/contract?action=list");
    }

    // =====================================================================
    // ADMIN – DETAIL
    // =====================================================================
    private void showDetail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isAdminOrStaff(request)) { redirect401(request, response); return; }

        int id = Integer.parseInt(request.getParameter("id"));
        Contract c = contractDAO.getDetailById(id);
        if (c == null) { response.sendRedirect(request.getContextPath() + "/contract?action=list"); return; }

        List<ContractUser> tenants = contractDAO.getTenantsWithInfo(id);
        List<Bill>         bills   = billDAO.getBillsByContractId(id);
        List<User>         customers = userDAO.getAllCustomers(null, "active");
        List<ContractTenant> contractTenants = contractDAO.getTenantsByContractId(id);

        // Build map userId -> User để JSP lấy phone, cccd
        Map<Integer, User> userInfoMap = new HashMap<>();
        for (ContractUser cu : tenants) {
            User u = userDAO.getUserByIdAny(cu.getUserId());
            if (u != null) userInfoMap.put(cu.getUserId(), u);
        }

        request.setAttribute("contract",        c);
        request.setAttribute("tenants",         tenants);
        request.setAttribute("bills",           bills);
        request.setAttribute("customers",       customers);
        request.setAttribute("contractTenants", contractTenants);
        request.setAttribute("userInfoMap",     userInfoMap);
        forward(request, response, "/views/admin/contracts/contractDetail.jsp");
    }

    // =====================================================================
    // ADMIN – TERMINATE  (với final bill tự động)
    // =====================================================================
    private void terminateContract(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        if (!isAdminOrStaff(request)) { redirect401(request, response); return; }

        int    contractId = Integer.parseInt(request.getParameter("id"));
        int    roomId     = Integer.parseInt(request.getParameter("roomId"));
        String reason     = request.getParameter("reason");
        if (reason == null) reason = "";

        Contract contract = contractDAO.getDetailById(contractId);
        if (contract == null) {
            flash(request, "contractError", "Contract not found.");
            response.sendRedirect(request.getContextPath() + "/contract?action=list");
            return;
        }

        // ── Ngày rời đi (moveOutDate) do admin nhập, mặc định = hôm nay ──
        String moveOutStr = request.getParameter("moveOutDate");
        LocalDate moveOutDate;
        try {
            moveOutDate = (moveOutStr != null && !moveOutStr.isEmpty())
                    ? LocalDate.parse(moveOutStr)
                    : LocalDate.now();
        } catch (Exception e) {
            moveOutDate = LocalDate.now();
        }

        // ── Tạo Final Bill (utility + service của tháng rời) ──
        int finalBillId = buildFinalBill(contract, moveOutDate, reason);

        // ── Terminate hợp đồng (giữ lại final bill, xóa các pending bill khác) ──
        contractDAO.terminate(contractId, roomId, reason, finalBillId);

        // ── Xử lý cọc ──
        User currentUser = currentUser(request);
        int createdBy = (currentUser != null) ? currentUser.getUserId() : 1;
        BigDecimal depositBalance = depositDAO.getBalance(contractId);
        LocalDate today = LocalDate.now();
        String message;

        if (contract.getEndDate() != null && !contract.getEndDate().isAfter(today)) {
            // Hết hạn đúng hạn → hoàn cọc
            if (depositBalance != null && depositBalance.compareTo(BigDecimal.ZERO) > 0) {
                DepositTransaction refund = new DepositTransaction();
                refund.setContractId(contractId);
                refund.setAmount(depositBalance);
                refund.setTransactionType(DepositTransaction.TYPE_REFUND);
                refund.setNote("Hoan tra coc khi het han hop dong");
                refund.setCreatedBy(createdBy);
                depositDAO.insert(refund);
            }
            message = "Contract #" + contractId + " terminated (fulfilled). Deposit refunded.";
        } else {
            // Trước hạn → giữ cọc
            if (depositBalance != null && depositBalance.compareTo(BigDecimal.ZERO) > 0) {
                DepositTransaction deduction = new DepositTransaction();
                deduction.setContractId(contractId);
                deduction.setAmount(depositBalance);
                deduction.setTransactionType(DepositTransaction.TYPE_DEDUCTION);
                deduction.setNote("Khong hoan tra coc do cham dut truoc han. Ly do: " + reason);
                deduction.setCreatedBy(createdBy);
                depositDAO.insert(deduction);
            }
            message = "Contract #" + contractId + " terminated (early). Deposit retained.";
        }

        if (finalBillId > 0) {
            message += " Final bill #" + finalBillId + " created (utility + service tháng "
                    + moveOutDate.getMonthValue() + "/" + moveOutDate.getYear() + ").";
        } else if (finalBillId == -2) {
            message += " (Final bill đã tồn tại cho kỳ này.)";
        }

        flash(request, "contractSuccess", message);
        response.sendRedirect(request.getContextPath() + "/contract?action=list");
    }

    /**
     * Tạo final bill khi hủy hợp đồng.
     *
     * NGUYÊN LÝ VẬN HÀNH:
     *  - Tháng N: thu tiền phòng tháng N+1 (advance) + điện/nước/service của tháng N
     *  - Khi rời vào tháng N: tiền phòng tháng N+1 đã thu rồi → KHÔNG thu lại.
     *    Chỉ cần thanh toán: điện/nước + service còn unbilled trong tháng N.
     *
     * @return billId nếu tạo thành công, -1 nếu lỗi, -2 nếu bill kỳ này đã tồn tại,
     *         0 nếu không có gì để tính (không tạo bill trống)
     */
    private int buildFinalBill(Contract contract, LocalDate moveOutDate, String terminationReason) {
        int contractId  = contract.getContractId();
        int roomId      = contract.getRoomId();

        // Kỳ thanh toán = tháng của ngày rời (luôn lấy ngày 1 theo constraint DB)
        LocalDate periodStart = moveOutDate.withDayOfMonth(1);
        LocalDate periodEnd   = moveOutDate.withDayOfMonth(moveOutDate.lengthOfMonth());

        // Kiểm tra bill kỳ này đã tồn tại chưa
        if (billDAO.existsByContractAndPeriod(contractId, periodStart)) {
            return -2;
        }

        List<BillItem> items            = new java.util.ArrayList<>();
        List<Integer>  utilityUsageIds  = new java.util.ArrayList<>();
        List<Integer>  serviceUsageIds  = new java.util.ArrayList<>();
        BigDecimal     total            = BigDecimal.ZERO;

        // ── 1. Điện / nước (utility_usage chưa billed trong kỳ) ──
        List<UtilityUsage> usages = utilityDAO.getUnbilledByRoomAndPeriod(roomId, periodStart);
        for (UtilityUsage uu : usages) {
            int consumption = uu.getConsumption();
            if (consumption <= 0) continue;

            BigDecimal rate = utilityDAO.getPriceAtDate(uu.getUtilityId(), periodStart);
            BigDecimal cons = BigDecimal.valueOf(consumption);
            BigDecimal line = cons.multiply(rate);

            int catId = priceDAO.getCategoryIdByUtilityName(uu.getUtilityName());
            if (catId <= 0) catId = priceDAO.getCategoryIdByCode("ELECTRICITY");

            BillItem item = new BillItem();
            item.setCategoryId(catId);
            item.setDescription(uu.getUtilityName()
                    + ": " + uu.getOldValue() + " → " + uu.getNewValue()
                    + " = " + consumption + " " + uu.getUnit()
                    + " x " + rate.toPlainString() + "đ");
            item.setQuantity(cons);
            item.setUnitPrice(rate);
            item.setSourceType("utility");
            item.setSourceId(uu.getUsageId());
            items.add(item);
            total = total.add(line);
            utilityUsageIds.add(uu.getUsageId());
        }

        // ── 2. Service đã approved, chưa billed trong kỳ ──
        List<ServiceUsage> services =
                serviceDAO.getUnbilledApprovedByContractAndPeriod(contractId, periodStart, periodEnd);
        for (ServiceUsage su : services) {
            BigDecimal price = su.getUnitPrice() != null ? su.getUnitPrice() : BigDecimal.ZERO;
            BigDecimal qty   = su.getQuantity()  != null ? su.getQuantity()  : BigDecimal.ONE;
            BigDecimal line  = qty.multiply(price);

            int catId = priceDAO.getCategoryIdByCode("SERVICE");

            String requester = su.getRequesterName() != null ? su.getRequesterName() : "Không rõ";
            BillItem item = new BillItem();
            item.setCategoryId(catId);
            item.setDescription(su.getServiceName()
                    + " x " + qty.toPlainString()
                    + " (ngày " + su.getUsageDate() + " - Y/c: " + requester + ")");
            item.setQuantity(qty);
            item.setUnitPrice(price);
            item.setSourceType("service");
            item.setSourceId(su.getUsageId());
            items.add(item);
            total = total.add(line);
            serviceUsageIds.add(su.getUsageId());
        }

        // ── Thêm dòng ghi chú lý do hủy (nếu có) — không tính tiền ──
        if (terminationReason != null && !terminationReason.isBlank()) {
            int noteCatId = priceDAO.getCategoryIdByCode("SERVICE"); // dùng category gần nhất
            BillItem noteItem = new BillItem();
            noteItem.setCategoryId(noteCatId);
            noteItem.setDescription("📝 Lý do hủy hợp đồng: " + terminationReason.trim());
            noteItem.setQuantity(BigDecimal.ZERO);
            noteItem.setUnitPrice(BigDecimal.ZERO);
            noteItem.setSourceType("note");
            items.add(noteItem);
            // total không thay đổi (0 * 0 = 0)
        }

        // Không tạo bill trống (chỉ có note mà không có dòng tiền thực → không tạo)
        boolean hasRealItem = items.stream()
                .anyMatch(i -> i.getUnitPrice() != null && i.getUnitPrice().compareTo(BigDecimal.ZERO) > 0);
        if (!hasRealItem) return 0;

        // ── Tạo bill ──
        Bill bill = new Bill();
        bill.setContractId(contractId);
        bill.setPeriod(periodStart);
        bill.setDueDate(moveOutDate.plusDays(3)); // hạn thanh toán 3 ngày sau ngày rời
        bill.setTotalAmount(total);
        bill.setStatus("pending");

        return billDAO.insertBillWithItems(bill, items, utilityUsageIds, serviceUsageIds);
    }

    // =====================================================================
    // ADMIN – DELETE
    // =====================================================================
    private void deleteContract(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        if (!isAdminOrStaff(request)) { redirect401(request, response); return; }

        int id = Integer.parseInt(request.getParameter("id"));
        contractDAO.delete(id);
        flash(request, "contractSuccess", "Contract deleted.");
        response.sendRedirect(request.getContextPath() + "/contract?action=list");
    }

    // =====================================================================
    // ADMIN – APPROVE / REJECT
    // =====================================================================
    private void approveContract(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        if (!isAdminOrStaff(request)) { redirect401(request, response); return; }

        int contractId = Integer.parseInt(request.getParameter("id"));
        contractDAO.approve(contractId);
        flash(request, "contractSuccess", "Contract #" + contractId + " approved and now active.");
        response.sendRedirect(request.getContextPath() + "/contract?action=detail&id=" + contractId);
    }

    private void rejectContract(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        if (!isAdminOrStaff(request)) { redirect401(request, response); return; }

        int contractId = Integer.parseInt(request.getParameter("id"));
        contractDAO.reject(contractId);
        flash(request, "contractSuccess", "Contract #" + contractId + " rejected.");
        response.sendRedirect(request.getContextPath() + "/contract?action=list");
    }

    // =====================================================================
    // CUSTOMER – REQUEST CANCELLATION
    // =====================================================================
    private void requestCancellation(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        User user = currentUser(request);
        if (user == null) { response.sendRedirect(request.getContextPath() + "/auth?action=login"); return; }

        int contractId = Integer.parseInt(request.getParameter("id"));
        Contract contract = contractDAO.getDetailById(contractId);
        if (contract == null || !contract.isActive()) {
            flash(request, "contractError", "Contract not found or cannot be cancelled.");
            response.sendRedirect(request.getContextPath() + "/contract?action=mycontract");
            return;
        }

        boolean ok = contractDAO.requestCancellation(contractId);
        if (ok) {
            flash(request, "contractSuccess", "Cancellation request submitted. An administrator will review it shortly.");
        } else {
            flash(request, "contractError", "Could not submit cancellation request.");
        }
        response.sendRedirect(request.getContextPath() + "/contract?action=mydetail&id=" + contractId);
    }

    // =====================================================================
    // ADMIN – APPROVE / REJECT CANCELLATION
    // =====================================================================
    private void approveCancellation(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        if (!isAdminOrStaff(request)) { redirect401(request, response); return; }

        int contractId = Integer.parseInt(request.getParameter("id"));
        Contract contract = contractDAO.getDetailById(contractId);
        if (contract == null) {
            flash(request, "contractError", "Contract not found.");
            response.sendRedirect(request.getContextPath() + "/contract?action=list");
            return;
        }

        // Ngày rời = hôm nay (hoặc admin có thể truyền qua param)
        String moveOutStr = request.getParameter("moveOutDate");
        LocalDate moveOutDate;
        try {
            moveOutDate = (moveOutStr != null && !moveOutStr.isEmpty())
                    ? LocalDate.parse(moveOutStr)
                    : LocalDate.now();
        } catch (Exception e) {
            moveOutDate = LocalDate.now();
        }

        // Tạo final bill trước khi terminate
        String cancelReason = "Cancellation approved by admin (customer requested)";
        int finalBillId = buildFinalBill(contract, moveOutDate, cancelReason);

        // Giữ lại final bill, xóa pending bills khác
        contractDAO.terminate(contractId, contract.getRoomId(), cancelReason, finalBillId);

        User currentUser = currentUser(request);
        int createdBy = (currentUser != null) ? currentUser.getUserId() : 1;
        BigDecimal depositBalance = depositDAO.getBalance(contractId);
        LocalDate today = LocalDate.now();
        String message;

        if (contract.getEndDate() != null && !contract.getEndDate().isAfter(today)) {
            if (depositBalance != null && depositBalance.compareTo(BigDecimal.ZERO) > 0) {
                DepositTransaction refund = new DepositTransaction();
                refund.setContractId(contractId);
                refund.setAmount(depositBalance);
                refund.setTransactionType(DepositTransaction.TYPE_REFUND);
                refund.setNote("Hoan tra coc khi het han hop dong");
                refund.setCreatedBy(createdBy);
                depositDAO.insert(refund);
            }
            message = "Contract #" + contractId + " cancellation approved. Deposit refunded.";
        } else {
            if (depositBalance != null && depositBalance.compareTo(BigDecimal.ZERO) > 0) {
                DepositTransaction deduction = new DepositTransaction();
                deduction.setContractId(contractId);
                deduction.setAmount(depositBalance);
                deduction.setTransactionType(DepositTransaction.TYPE_DEDUCTION);
                deduction.setNote("Khong hoan tra coc do cham dut truoc han (khach hang yeu cau huy).");
                deduction.setCreatedBy(createdBy);
                depositDAO.insert(deduction);
            }
            message = "Contract #" + contractId + " cancellation approved. Deposit retained.";
        }

        if (finalBillId > 0) {
            message += " Final bill #" + finalBillId + " created (utility + service tháng "
                    + moveOutDate.getMonthValue() + "/" + moveOutDate.getYear() + ").";
        } else if (finalBillId == -2) {
            message += " (Final bill đã tồn tại cho kỳ này.)";
        }

        flash(request, "contractSuccess", message);
        response.sendRedirect(request.getContextPath() + "/contract?action=list");
    }

    private void rejectCancellation(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        if (!isAdminOrStaff(request)) { redirect401(request, response); return; }

        int contractId = Integer.parseInt(request.getParameter("id"));
        contractDAO.rejectCancellation(contractId);
        flash(request, "contractSuccess", "Cancellation request rejected. Contract #" + contractId + " remains active.");
        response.sendRedirect(request.getContextPath() + "/contract?action=list");
    }

    // =====================================================================
    // ADMIN – CO-TENANTS
    // =====================================================================
    private void showAddTenantForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isAdminOrStaff(request)) { redirect401(request, response); return; }

        int id = Integer.parseInt(request.getParameter("id"));
        Contract c = contractDAO.getDetailById(id);
        List<ContractUser> tenants   = contractDAO.getTenantsWithInfo(id);
        List<User>         customers = userDAO.getAllCustomers(null, "active");

        request.setAttribute("contract",  c);
        request.setAttribute("tenants",   tenants);
        request.setAttribute("customers", customers);
        forward(request, response, "/views/admin/contracts/manageTenants.jsp");
    }

    private void addTenant(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        if (!isAdminOrStaff(request)) { redirect401(request, response); return; }

        try {
            int       contractId = Integer.parseInt(request.getParameter("contractId"));
            int       userId     = Integer.parseInt(request.getParameter("userId"));
            String    role       = request.getParameter("role");
            String    joinedStr  = request.getParameter("joinedAt");
            LocalDate joinedAt   = (joinedStr == null || joinedStr.isEmpty()) ? LocalDate.now() : LocalDate.parse(joinedStr);

            // One active contract per person at a time
            if (contractDAO.hasActiveContract(userId)) {
                flash(request, "contractError",
                        "This person already has an active contract. They must leave their current contract first.");
                response.sendRedirect(request.getContextPath() + "/contract?action=addTenant&id=" + contractId);
                return;
            }

            boolean ok = contractDAO.addTenant(contractId, userId, role, joinedAt);
            if (ok) {
                flash(request, "contractSuccess", "Tenant added successfully!");
            } else {
                flash(request, "contractError", "Tenant already exists in this contract.");
            }
            response.sendRedirect(request.getContextPath() + "/contract?action=addTenant&id=" + contractId);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/contract?action=list");
        }
    }

    private void removeTenant(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        if (!isAdminOrStaff(request)) { redirect401(request, response); return; }

        int contractId = Integer.parseInt(request.getParameter("contractId"));
        int userId     = Integer.parseInt(request.getParameter("userId"));
        contractDAO.removeTenant(contractId, userId);
        flash(request, "contractSuccess", "Tenant removed from contract.");
        response.sendRedirect(request.getContextPath() + "/contract?action=addTenant&id=" + contractId);
    }

    // =====================================================================
    // CUSTOMER – MY CONTRACTS
    // =====================================================================
    private void myContracts(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = currentUser(request);
        if (user == null) { response.sendRedirect(request.getContextPath() + "/auth?action=login"); return; }

        int totalItems = contractDAO.countContractsByUserId(user.getUserId());
        int totalPages = Math.max(1, (int) Math.ceil((double) totalItems / PAGE_SIZE));
        int page = parsePage(request.getParameter("page"), totalPages);
        int offset = (page - 1) * PAGE_SIZE;

        List<Contract> contracts = contractDAO.getContractsByUserIdPaginated(user.getUserId(), PAGE_SIZE, offset);
        request.setAttribute("contracts", contracts);
        request.setAttribute("totalItems", totalItems);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("currentPage", page);
        request.setAttribute("pageSize", PAGE_SIZE);
        forward(request, response, "/views/customer/contracts.jsp");
    }

    // =====================================================================
    // CUSTOMER – MY CONTRACT DETAIL
    // =====================================================================
    private void myContractDetail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = currentUser(request);
        if (user == null) { response.sendRedirect(request.getContextPath() + "/auth?action=login"); return; }

        int id = Integer.parseInt(request.getParameter("id"));
        Contract c = contractDAO.getDetailById(id);

        // Security: verify this user belongs to this contract
        List<ContractUser> tenants = contractDAO.getTenantsWithInfo(id);
        boolean belongs = tenants.stream().anyMatch(t -> t.getUserId() == user.getUserId());
        if (c == null || !belongs) {
            response.sendRedirect(request.getContextPath() + "/contract?action=mycontract");
            return;
        }

        List<Bill> bills = billDAO.getBillsByContractId(id);
        List<ContractTenant> contractTenants = contractDAO.getTenantsByContractId(id);
        request.setAttribute("contract",        c);
        request.setAttribute("tenants",         tenants);
        request.setAttribute("bills",           bills);
        request.setAttribute("contractTenants", contractTenants);
        forward(request, response, "/views/customer/contractDetail.jsp");
    }

    // =====================================================================
    // CUSTOMER – SIGN CONTRACT (browse available rooms → select → sign)
    // =====================================================================
    private void showSignContractForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = currentUser(request);
        if (user == null) { response.sendRedirect(request.getContextPath() + "/auth?action=login"); return; }

        // Pass active-contract flag so JSP can warn/block
        boolean alreadyHasContract = contractDAO.hasActiveContract(user.getUserId());
        request.setAttribute("alreadyHasContract", alreadyHasContract);

        String roomIdStr = request.getParameter("roomId");
        if (roomIdStr != null) {
            Room room = roomDAO.getRoomById(Integer.parseInt(roomIdStr));
            request.setAttribute("room", room);
            // Pass all active facilities so customer can pick optional amenities
            request.setAttribute("facilities", facilityDAO.getAllFacilities());
        } else {
            List<Room> availableRooms = roomDAO.getByStatus("available");
            request.setAttribute("availableRooms", availableRooms);
        }
        forward(request, response, "/views/customer/signContract.jsp");
    }

    // =====================================================================
    // ADMIN – CONTRACT_TENANT CRUD
    // =====================================================================

    /** GET: show add-tenant form (blank) or edit-tenant form (prefilled) */
    private void showAddContractTenantForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isAdminOrStaff(request)) { redirect401(request, response); return; }
        int contractId = Integer.parseInt(request.getParameter("id"));
        Contract c = contractDAO.getDetailById(contractId);
        if (c == null) { response.sendRedirect(request.getContextPath() + "/contract?action=list"); return; }
        request.setAttribute("contract", c);
        request.setAttribute("contractTenants", contractDAO.getTenantsByContractId(contractId));
        // blank form for add
        request.setAttribute("editTenant", null);
        forward(request, response, "/views/admin/contracts/manageContractTenants.jsp");
    }

    private void showEditContractTenantForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isAdminOrStaff(request)) { redirect401(request, response); return; }
        int tenantId   = Integer.parseInt(request.getParameter("tenantId"));
        ContractTenant t = contractDAO.getTenantById(tenantId);
        if (t == null) { response.sendRedirect(request.getContextPath() + "/contract?action=list"); return; }
        Contract c = contractDAO.getDetailById(t.getContractId());
        request.setAttribute("contract",        c);
        request.setAttribute("contractTenants", contractDAO.getTenantsByContractId(t.getContractId()));
        request.setAttribute("editTenant",      t);
        forward(request, response, "/views/admin/contracts/manageContractTenants.jsp");
    }

    /** POST: add or update a contract_tenant record */
    private void saveContractTenant(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        if (!isAdminOrStaff(request)) { redirect401(request, response); return; }
        try {
            int    contractId = Integer.parseInt(request.getParameter("contractId"));
            String tenantIdStr = request.getParameter("tenantId");
            String fullName   = request.getParameter("fullName");
            String phone      = request.getParameter("phone");
            String cccd       = request.getParameter("cccd");
            String bdStr      = request.getParameter("birthDate");
            boolean isPrimary = "1".equals(request.getParameter("isPrimary"));

            ContractTenant t = new ContractTenant();
            t.setContractId(contractId);
            t.setFullName(fullName);
            t.setPhone(phone != null ? phone : "");
            t.setCccd(cccd != null ? cccd : "");
            t.setBirthDate((bdStr != null && !bdStr.isEmpty()) ? LocalDate.parse(bdStr) : null);
            t.setPrimary(isPrimary);

            boolean ok;
            if (tenantIdStr != null && !tenantIdStr.isEmpty()) {
                // update existing
                t.setTenantId(Integer.parseInt(tenantIdStr));
                ok = contractDAO.updateContractTenant(t);
                flash(request, "contractSuccess", ok ? "Occupant updated." : "Update failed.");
            } else {
                // add new
                ok = contractDAO.addContractTenant(t);
                flash(request, "contractSuccess", ok ? "Occupant added." : "Failed to add occupant.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            flash(request, "contractError", "Invalid input: " + e.getMessage());
        }
        int contractId = Integer.parseInt(request.getParameter("contractId"));
        response.sendRedirect(request.getContextPath() + "/contract?action=addContractTenant&id=" + contractId);
    }

    /** GET: delete a contract_tenant row */
    private void removeContractTenant(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        if (!isAdminOrStaff(request)) { redirect401(request, response); return; }
        int tenantId   = Integer.parseInt(request.getParameter("tenantId"));
        int contractId = Integer.parseInt(request.getParameter("contractId"));
        contractDAO.removeContractTenant(tenantId);
        flash(request, "contractSuccess", "Occupant removed.");
        response.sendRedirect(request.getContextPath() + "/contract?action=addContractTenant&id=" + contractId);
    }

    // =====================================================================
    // HELPERS
    // =====================================================================
    private void forward(HttpServletRequest req, HttpServletResponse res, String path)
            throws ServletException, IOException {
        req.getRequestDispatcher(path).forward(req, res);
    }

    private void flash(HttpServletRequest req, String key, String msg) {
        req.getSession().setAttribute(key, msg);
    }

    private void redirect401(HttpServletRequest req, HttpServletResponse res)
            throws IOException {
        User u = currentUser(req);
        if (u == null) {
            // Not logged in → go to login
            res.sendRedirect(req.getContextPath() + "/auth?action=login");
        } else {
            // Logged in but not authorized → send to customer area with error
            flash(req, "contractError", "You don't have permission to access that page.");
            res.sendRedirect(req.getContextPath() + "/contract?action=mycontract");
        }
    }

    private int parsePage(String param, int max) {
        try { int p = Integer.parseInt(param); return Math.min(Math.max(p, 1), max); }
        catch (Exception e) { return 1; }
    }

    private User currentUser(HttpServletRequest req) {
        HttpSession s = req.getSession(false);
        return (s != null) ? (User) s.getAttribute("user") : null;
    }

    private boolean isAdminOrStaff(HttpServletRequest req) {
        User u = currentUser(req);
        if (u == null) return false;
        return "admin".equalsIgnoreCase(u.getRole()) || "staff".equalsIgnoreCase(u.getRole());
    }

    /** Phone validation: null/blank passes; non-blank must match Vietnamese mobile format */
    private boolean isValidPhone(String phone) {
        return phone == null || phone.isBlank()
            || phone.matches("^(0[35789])\\d{8}$");
    }

    // =====================================================================
    // AJAX: Get user info as JSON (for auto-fill in createContract.jsp)
    // =====================================================================
    private void getUserInfo(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        try {
            String idStr = request.getParameter("id");
            if (idStr == null || idStr.isEmpty()) {
                response.getWriter().write("{\"error\":\"id required\"}");
                return;
            }
            int userId = Integer.parseInt(idStr);
            User u = userDAO.getUserById(userId);
            if (u == null) {
                response.getWriter().write("{\"error\":\"user not found\"}");
                return;
            }
            // Return JSON with user info
            String json = String.format(
                "{\"fullName\":\"%s\",\"phone\":\"%s\",\"cccd\":\"%s\"}",
                escapeJson(u.getFullName() != null ? u.getFullName() : ""),
                escapeJson(u.getPhone() != null ? u.getPhone() : ""),
                escapeJson(u.getCccd() != null ? u.getCccd() : "")
            );
            response.getWriter().write(json);
        } catch (Exception e) {
            response.setStatus(400);
            response.getWriter().write("{\"error\":\"" + e.getMessage() + "\"}");
        }
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }
}