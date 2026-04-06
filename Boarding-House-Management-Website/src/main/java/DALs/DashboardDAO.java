package DALs;

import Utils.DBContext;
import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Aggregation queries for the admin dashboard.
 * All queries are read-only. Keep each query fast (indexed columns only).
 */
public class DashboardDAO extends DBContext {

    // ==============================
    // KPI: Room occupancy stats
    // ==============================
    public Map<String, Integer> getRoomStats() {
        Map<String, Integer> m = new LinkedHashMap<>();
        String sql = "SELECT "
                   + "SUM(CASE WHEN status='available'   THEN 1 ELSE 0 END) AS available, "
                   + "SUM(CASE WHEN status='occupied'    THEN 1 ELSE 0 END) AS occupied, "
                   + "SUM(CASE WHEN status='maintenance' THEN 1 ELSE 0 END) AS maintenance, "
                   + "COUNT(*) AS total "
                   + "FROM room WHERE is_deleted=0";
        try (PreparedStatement st = connection.prepareStatement(sql);
             ResultSet rs = st.executeQuery()) {
            if (rs.next()) {
                m.put("available",   rs.getInt("available"));
                m.put("occupied",    rs.getInt("occupied"));
                m.put("maintenance", rs.getInt("maintenance"));
                m.put("total",       rs.getInt("total"));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return m;
    }

    // ==============================
    // KPI: Bill payment summary
    // ==============================
    public Map<String, Object> getBillStats() {
        Map<String, Object> m = new LinkedHashMap<>();
        String sql = "SELECT "
                   + "COUNT(*) AS total, "
                   + "SUM(CASE WHEN status='pending' THEN 1 ELSE 0 END) AS pending, "
                   + "SUM(CASE WHEN status='paid'    THEN 1 ELSE 0 END) AS paid, "
                   + "SUM(CASE WHEN status='overdue' THEN 1 ELSE 0 END) AS overdue, "
                   + "SUM(CASE WHEN status='paid' THEN total_amount ELSE 0 END) AS revenue_paid, "
                   + "SUM(CASE WHEN status IN ('pending','overdue') THEN total_amount ELSE 0 END) AS revenue_outstanding "
                   + "FROM bill WHERE is_deleted=0";
        try (PreparedStatement st = connection.prepareStatement(sql);
             ResultSet rs = st.executeQuery()) {
            if (rs.next()) {
                m.put("total",               rs.getInt("total"));
                m.put("pending",             rs.getInt("pending"));
                m.put("paid",                rs.getInt("paid"));
                m.put("overdue",             rs.getInt("overdue"));
                m.put("revenuePaid",         rs.getBigDecimal("revenue_paid"));
                m.put("revenueOutstanding",  rs.getBigDecimal("revenue_outstanding"));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return m;
    }

    // ==============================
    // KPI: Active contracts count
    // ==============================
    public int getActiveContractCount() {
        String sql = "SELECT COUNT(*) FROM contract WHERE status='active' AND is_deleted=0";
        try (PreparedStatement st = connection.prepareStatement(sql);
             ResultSet rs = st.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }

    // ==============================
    // KPI: Pending service requests
    // ==============================
    public int getPendingServiceRequestCount() {
        String sql = "SELECT COUNT(*) FROM service_usage WHERE status='pending'";
        try (PreparedStatement st = connection.prepareStatement(sql);
             ResultSet rs = st.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }

    // ==============================
    // CHART: Monthly revenue (last 6 months)
    // Returns list of {month, paid, outstanding}
    // ==============================
    public List<Map<String, Object>> getMonthlyRevenue() {
        List<Map<String, Object>> result = new ArrayList<>();
        String sql = "SELECT TOP 6 "
                   + "FORMAT(period,'yyyy-MM') AS month, "
                   + "SUM(CASE WHEN status='paid' THEN total_amount ELSE 0 END) AS paid, "
                   + "SUM(CASE WHEN status IN ('pending','overdue') THEN total_amount ELSE 0 END) AS outstanding "
                   + "FROM bill WHERE is_deleted=0 "
                   + "GROUP BY FORMAT(period,'yyyy-MM') "
                   + "ORDER BY month DESC";
        try (PreparedStatement st = connection.prepareStatement(sql);
             ResultSet rs = st.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> row = new LinkedHashMap<>();
                row.put("month",       rs.getString("month"));
                row.put("paid",        rs.getBigDecimal("paid"));
                row.put("outstanding", rs.getBigDecimal("outstanding"));
                result.add(row);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        Collections.reverse(result); // oldest first for chart
        return result;
    }

    // ==============================
    // TABLE: Contracts expiring within 30 days
    // ==============================
    public List<Map<String, Object>> getExpiringContracts() {
        List<Map<String, Object>> result = new ArrayList<>();
        LocalDate today = LocalDate.now();
        LocalDate in30  = today.plusDays(30);
        String sql = "SELECT c.contract_id, r.room_number, c.end_date, "
                   + "ISNULL(u.full_name, ct.full_name) AS tenant_name, "
                   + "DATEDIFF(day, GETDATE(), c.end_date) AS days_left "
                   + "FROM contract c "
                   + "JOIN room r ON c.room_id = r.room_id "
                   + "LEFT JOIN contract_user cu ON c.contract_id = cu.contract_id AND cu.role='owner' "
                   + "LEFT JOIN [user] u ON cu.user_id = u.user_id "
                   + "LEFT JOIN contract_tenant ct ON c.contract_id = ct.contract_id AND ct.is_primary=1 "
                   + "WHERE c.status='active' AND c.end_date IS NOT NULL "
                   + "  AND c.end_date BETWEEN ? AND ? AND c.is_deleted=0 "
                   + "ORDER BY c.end_date ASC";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setDate(1, Date.valueOf(today));
            st.setDate(2, Date.valueOf(in30));
            ResultSet rs = st.executeQuery();
            while (rs.next()) {
                Map<String, Object> row = new LinkedHashMap<>();
                row.put("contractId", rs.getInt("contract_id"));
                row.put("roomNumber", rs.getString("room_number"));
                row.put("endDate",    rs.getDate("end_date").toLocalDate().toString());
                row.put("tenantName", rs.getString("tenant_name"));
                row.put("daysLeft",   rs.getInt("days_left"));
                result.add(row);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return result;
    }

    // ==============================
    // TABLE: Recent overdue bills
    // ==============================
    public List<Map<String, Object>> getOverdueBills() {
        List<Map<String, Object>> result = new ArrayList<>();
        String sql = "SELECT TOP 10 b.bill_id, r.room_number, b.period, b.due_date, "
                   + "b.total_amount, ISNULL(u.full_name, ct.full_name) AS tenant_name "
                   + "FROM bill b "
                   + "JOIN contract c ON b.contract_id = c.contract_id "
                   + "JOIN room r ON c.room_id = r.room_id "
                   + "LEFT JOIN contract_user cu ON c.contract_id = cu.contract_id AND cu.role='owner' "
                   + "LEFT JOIN [user] u ON cu.user_id = u.user_id "
                   + "LEFT JOIN contract_tenant ct ON c.contract_id = ct.contract_id AND ct.is_primary=1 "
                   + "WHERE b.status='overdue' AND b.is_deleted=0 "
                   + "ORDER BY b.due_date ASC";
        try (PreparedStatement st = connection.prepareStatement(sql);
             ResultSet rs = st.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> row = new LinkedHashMap<>();
                row.put("billId",     rs.getInt("bill_id"));
                row.put("roomNumber", rs.getString("room_number"));
                row.put("period",     rs.getDate("period").toLocalDate().toString());
                row.put("dueDate",    rs.getDate("due_date").toLocalDate().toString());
                row.put("amount",     rs.getBigDecimal("total_amount"));
                row.put("tenantName", rs.getString("tenant_name"));
                result.add(row);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return result;
    }

    // ==============================
    // TABLE: Pending service requests (last 10)
    // ==============================
    public List<Map<String, Object>> getPendingServiceRequests() {
        List<Map<String, Object>> result = new ArrayList<>();
        String sql = "SELECT TOP 10 su.usage_id, su.usage_date, su.quantity, "
                   + "s.service_name, r.room_number, "
                   + "ISNULL(u.full_name, 'N/A') AS requester "
                   + "FROM service_usage su "
                   + "JOIN service s ON su.service_id = s.service_id "
                   + "JOIN contract c ON su.contract_id = c.contract_id "
                   + "JOIN room r ON c.room_id = r.room_id "
                   + "LEFT JOIN contract_user cu ON c.contract_id = cu.contract_id AND cu.role='owner' "
                   + "LEFT JOIN [user] u ON cu.user_id = u.user_id "
                   + "WHERE su.status='pending' "
                   + "ORDER BY su.usage_date DESC";
        try (PreparedStatement st = connection.prepareStatement(sql);
             ResultSet rs = st.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> row = new LinkedHashMap<>();
                row.put("usageId",     rs.getInt("usage_id"));
                row.put("usageDate",   rs.getDate("usage_date").toLocalDate().toString());
                row.put("quantity",    rs.getBigDecimal("quantity"));
                row.put("serviceName", rs.getString("service_name"));
                row.put("roomNumber",  rs.getString("room_number"));
                row.put("requester",   rs.getString("requester"));
                result.add(row);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return result;
    }
}
