package DALs;

import Models.PaymentTransaction;
import Utils.DBContext;

import java.sql.*;
import java.math.BigDecimal;

public class PaymentDAO extends DBContext {

    // ==============================
    // INSERT PAYMENT TRANSACTION
    // ==============================
    public void insert(PaymentTransaction pt) {
        String sql = "INSERT INTO payment_transaction "
                + "(bill_id, vnp_txn_ref, amount, status, created_at, updated_at) "
                + "VALUES (?, ?, ?, ?, GETDATE(), GETDATE())";

        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, pt.getBillId());
            st.setString(2, pt.getVnpTxnRef());
            st.setBigDecimal(3, pt.getAmount());
            st.setString(4, pt.getStatus());
            st.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // ==============================
    // GET BY VNP_TXN_REF
    // ==============================
    public PaymentTransaction getByTxnRef(String vnpTxnRef) {
        String sql = "SELECT * FROM payment_transaction WHERE vnp_txn_ref = ?";

        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setString(1, vnpTxnRef);
            ResultSet rs = st.executeQuery();
            if (rs.next()) {
                return mapRow(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    // ==============================
    // UPDATE STATUS + RESPONSE FIELDS
    // ==============================
    public void updateStatus(String vnpTxnRef, String status, String responseCode,
            String bankCode, String transactionNo, String gatewayResponse) {

        String sql = "UPDATE payment_transaction "
                + "SET status = ?, vnp_response_code = ?, vnp_bank_code = ?, "
                + "vnp_transaction_no = ?, gateway_response = ?, updated_at = GETDATE() "
                + "WHERE vnp_txn_ref = ?";

        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setString(1, status);
            st.setString(2, responseCode);
            st.setString(3, bankCode);
            st.setString(4, transactionNo);
            st.setString(5, gatewayResponse);
            st.setString(6, vnpTxnRef);
            st.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // ==============================
    // MAP RESULTSET -> PAYMENTTRANSACTION
    // ==============================
    private PaymentTransaction mapRow(ResultSet rs) throws SQLException {
        PaymentTransaction pt = new PaymentTransaction();
        pt.setPaymentId(rs.getInt("payment_id"));
        pt.setBillId(rs.getInt("bill_id"));
        pt.setVnpTxnRef(rs.getString("vnp_txn_ref"));
        pt.setAmount(rs.getBigDecimal("amount"));
        pt.setStatus(rs.getString("status"));
        pt.setVnpResponseCode(rs.getString("vnp_response_code"));
        pt.setVnpBankCode(rs.getString("vnp_bank_code"));
        pt.setVnpTransactionNo(rs.getString("vnp_transaction_no"));
        pt.setGatewayResponse(rs.getString("gateway_response"));

        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) pt.setCreatedAt(createdAt.toLocalDateTime());

        Timestamp updatedAt = rs.getTimestamp("updated_at");
        if (updatedAt != null) pt.setUpdatedAt(updatedAt.toLocalDateTime());

        return pt;
    }
}
