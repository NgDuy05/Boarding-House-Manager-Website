package DALs;

import Models.Bill;
import Models.BillItem;
import Utils.DBContext;

import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.math.BigDecimal;

public class BillDAO extends DBContext {

    // ==============================
    // GET ALL BILLS
    // ==============================
    public List<Bill> getAllBills() {

        List<Bill> list = new ArrayList<>();

        String sql = "SELECT * FROM bill WHERE is_deleted = 0 ORDER BY bill_id DESC";

        try (PreparedStatement st = connection.prepareStatement(sql); ResultSet rs = st.executeQuery()) {

            while (rs.next()) {
                list.add(mapBill(rs));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    // ==============================
    // GET BILL BY ID
    // ==============================
    public Bill getBillById(int id) {

        String sql = "SELECT * FROM bill WHERE bill_id = ? AND is_deleted = 0";

        try (PreparedStatement st = connection.prepareStatement(sql)) {

            st.setInt(1, id);

            ResultSet rs = st.executeQuery();

            if (rs.next()) {
                return mapBill(rs);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    // ==============================
    // GET BILL BY TENANT
    // ==============================
    public List<Bill> getBillByTenant(int userId) {

        List<Bill> list = new ArrayList<>();

        // contract has no user_id column — link through contract_user junction table
        String sql = "SELECT b.* "
                + "FROM bill b "
                + "JOIN contract_user cu ON b.contract_id = cu.contract_id "
                + "WHERE cu.user_id = ? AND b.is_deleted = 0 "
                + "ORDER BY b.bill_id DESC";

        try (PreparedStatement st = connection.prepareStatement(sql)) {

            st.setInt(1, userId);

            ResultSet rs = st.executeQuery();

            while (rs.next()) {
                list.add(mapBill(rs));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    // ==============================
    // GET BILLS BY CONTRACT
    // ==============================
    public List<Bill> getBillsByContractId(int contractId) {
        List<Bill> list = new ArrayList<>();
        String sql = "SELECT * FROM bill WHERE contract_id = ? AND is_deleted = 0 ORDER BY period DESC";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, contractId);
            ResultSet rs = st.executeQuery();
            while (rs.next()) list.add(mapBill(rs));
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    // ==============================
    // GET UNPAID BILLS
    // ==============================
    public List<Bill> getUnpaidBills() {

        List<Bill> list = new ArrayList<>();

        String sql = "SELECT * FROM bill "
                + "WHERE status = 'pending' "
                + "AND is_deleted = 0";
        try (PreparedStatement st = connection.prepareStatement(sql); ResultSet rs = st.executeQuery()) {

            while (rs.next()) {
                list.add(mapBill(rs));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    // ==============================
    // INSERT BILL
    // ==============================
    public void insertBill(Bill b) {

        String sql = "INSERT INTO bill "
                + "(contract_id, period, due_date, total_amount, status, is_deleted) "
                + "VALUES (?, ?, ?, ?, ?, 0)";

        try (PreparedStatement st = connection.prepareStatement(sql)) {

            st.setInt(1, b.getContractId());
            st.setDate(2, Date.valueOf(b.getPeriod()));
            st.setDate(3, Date.valueOf(b.getDueDate()));
            st.setBigDecimal(4, b.getTotalAmount());
            st.setString(5, b.getStatus());

            st.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // ==============================
    // UPDATE BILL
    // ==============================
    public void updateBill(Bill b) {

        String sql = "UPDATE bill "
                + "SET contract_id = ?, "
                + "period = ?, "
                + "due_date = ?, "
                + "total_amount = ?, "
                + "status = ? "
                + "WHERE bill_id = ?";

        try (PreparedStatement st = connection.prepareStatement(sql)) {

            st.setInt(1, b.getContractId());
            st.setDate(2, Date.valueOf(b.getPeriod()));
            st.setDate(3, Date.valueOf(b.getDueDate()));
            st.setBigDecimal(4, b.getTotalAmount());
            st.setString(5, b.getStatus());
            st.setInt(6, b.getBillId());

            st.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // ==============================
    // SOFT DELETE
    // ==============================
    public void deleteBill(int id) {

        String sql = "UPDATE bill SET is_deleted = 1 WHERE bill_id = ?";

        try (PreparedStatement st = connection.prepareStatement(sql)) {

            st.setInt(1, id);

            st.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // ==============================
    // CALCULATE TOTAL BILL
    // (DEPRECATED — replaced by BillPreviewServlet; kept for backward compat)
    // ==============================
    public BigDecimal calculateTotal(int contractId) {

        String sql = "SELECT rc.base_price AS room_price, "
                + "ISNULL(SUM(su.quantity * ISNULL(ph.price_amount, 0)), 0) AS service_cost "
                + "FROM contract c "
                + "JOIN room r ON c.room_id = r.room_id "
                + "JOIN room_category rc ON r.category_id = rc.category_id "
                + "LEFT JOIN service_usage su ON su.contract_id = c.contract_id "
                + "  AND su.billed = 0 AND su.status = 'approved' "
                + "LEFT JOIN service svc ON svc.service_id = su.service_id "
                + "LEFT JOIN price_history ph ON svc.category_id = ph.category_id "
                + "  AND ph.effective_from = (SELECT TOP 1 effective_from FROM price_history "
                + "    WHERE category_id = svc.category_id AND effective_from <= su.usage_date "
                + "    ORDER BY effective_from DESC) "
                + "WHERE c.contract_id = ? "
                + "GROUP BY rc.base_price";

        try (PreparedStatement st = connection.prepareStatement(sql)) {

            st.setInt(1, contractId);

            ResultSet rs = st.executeQuery();

            if (rs.next()) {

                BigDecimal room = rs.getBigDecimal("room_price");
                BigDecimal service = rs.getBigDecimal("service_cost");

                if (service == null) {
                    service = BigDecimal.ZERO;
                }

                return room.add(service);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return BigDecimal.ZERO;
    }

    // ==============================
    // AUTO CREATE BILL EVERY MONTH
    // ==============================
    public void createMonthlyBill(int contractId) {

        LocalDate today = LocalDate.now();

        LocalDate period = LocalDate.of(today.getYear(), today.getMonth(), 1);

        LocalDate dueDate = period.plusDays(10);

        BigDecimal total = calculateTotal(contractId);

        Bill bill = new Bill();

        bill.setContractId(contractId);
        bill.setPeriod(period);
        bill.setDueDate(dueDate);
        bill.setTotalAmount(total);
        bill.setStatus("pending");

        insertBill(bill);
    }

    // ==============================
    // CHECK BILL EXISTS FOR MONTH
    // ==============================
    public boolean billExists(int contractId, LocalDate period) {

        String sql = "SELECT COUNT(*) "
                + "FROM bill "
                + "WHERE contract_id = ? "
                + "AND period = ?";

        try (PreparedStatement st = connection.prepareStatement(sql)) {

            st.setInt(1, contractId);
            st.setDate(2, Date.valueOf(period));

            ResultSet rs = st.executeQuery();

            if (rs.next()) {
                return rs.getInt(1) > 0;
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    // ==============================
    // MAP RESULTSET -> BILL
    // ==============================
    private Bill mapBill(ResultSet rs) throws SQLException {

        return new Bill(
                rs.getInt("bill_id"),
                rs.getInt("contract_id"),
                rs.getDate("period").toLocalDate(),
                rs.getDate("due_date").toLocalDate(),
                rs.getBigDecimal("total_amount"),
                rs.getString("status"),
                rs.getBoolean("is_deleted")
        );
    }

    // ==============================
    // GET BILLS WITH ROOM NUMBER
    // (owner bill-list / status views)
    // ==============================
    public List<Bill> getBillsWithRoomInfo() {
        List<Bill> list = new ArrayList<>();
        String sql = "SELECT b.*, r.room_number "
                   + "FROM bill b "
                   + "JOIN contract c ON b.contract_id = c.contract_id "
                   + "JOIN room r     ON c.room_id = r.room_id "
                   + "WHERE b.is_deleted = 0 "
                   + "ORDER BY b.bill_id DESC";
        try (PreparedStatement st = connection.prepareStatement(sql);
             ResultSet rs = st.executeQuery()) {
            while (rs.next()) {
                Bill b = mapBill(rs);
                b.setRoomNumber(rs.getString("room_number"));
                list.add(b);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // ==============================
    // GET BILL ITEMS BY BILL ID
    // ==============================
    public List<BillItem> getBillItemsByBillId(int billId) {
        List<BillItem> list = new ArrayList<>();
        String sql = "SELECT * FROM bill_item WHERE bill_id = ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, billId);
            ResultSet rs = st.executeQuery();
            while (rs.next()) {
                list.add(mapBillItem(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // ==============================
    // CHECK DUPLICATE: contract + period unique constraint
    // ==============================
    public boolean existsByContractAndPeriod(int contractId, java.time.LocalDate period) {
        String sql = "SELECT 1 FROM bill WHERE contract_id = ? AND period = ? AND is_deleted = 0";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, contractId);
            st.setDate(2, java.sql.Date.valueOf(period));
            try (java.sql.ResultSet rs = st.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // ==============================
    // INSERT BILL + ITEMS (transaction)
    // Returns new bill_id or -1 on failure
    // ==============================
    public int insertBillWithItems(Bill bill, List<BillItem> items,
                                   List<Integer> utilityUsageIds,
                                   List<Integer> serviceUsageIds) {
        String insertBillSql = "INSERT INTO bill "
                + "(contract_id, period, due_date, total_amount, status, created_at, is_deleted) "
                + "VALUES (?, ?, ?, ?, ?, GETDATE(), 0)";
        String insertItemSql = "INSERT INTO bill_item "
                + "(bill_id, category_id, description, quantity, unit_price, source_type, source_id) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?)";
        try {
            connection.setAutoCommit(false);

            // Step 1: insert bill, get generated id
            int newBillId;
            try (PreparedStatement st = connection.prepareStatement(
                    insertBillSql, Statement.RETURN_GENERATED_KEYS)) {
                st.setInt(1, bill.getContractId());
                st.setDate(2, Date.valueOf(bill.getPeriod()));
                st.setDate(3, Date.valueOf(bill.getDueDate()));
                st.setBigDecimal(4, bill.getTotalAmount());
                st.setString(5, bill.getStatus() != null ? bill.getStatus() : "pending");
                st.executeUpdate();
                ResultSet keys = st.getGeneratedKeys();
                if (!keys.next()) { connection.rollback(); return -1; }
                newBillId = keys.getInt(1);
            }

            // Step 2: insert each item
            try (PreparedStatement st = connection.prepareStatement(insertItemSql)) {
                for (BillItem item : items) {
                    st.setInt(1, newBillId);
                    st.setInt(2, item.getCategoryId());
                    st.setString(3, item.getDescription());
                    st.setBigDecimal(4, item.getQuantity());
                    st.setBigDecimal(5, item.getUnitPrice());
                    st.setString(6, item.getSourceType());
                    if (item.getSourceId() != null) {
                        st.setInt(7, item.getSourceId());
                    } else {
                        st.setNull(7, java.sql.Types.INTEGER);
                    }
                    st.addBatch();
                }
                st.executeBatch();
            }

            // Step 3: mark utility_usage as billed
            if (!utilityUsageIds.isEmpty()) {
                String inClause = utilityUsageIds.stream()
                    .map(String::valueOf).collect(java.util.stream.Collectors.joining(","));
                String markUtilSql = "UPDATE utility_usage SET billed=1, bill_id=? WHERE usage_id IN (" + inClause + ")";
                try (PreparedStatement markSt = connection.prepareStatement(markUtilSql)) {
                    markSt.setInt(1, newBillId);
                    markSt.executeUpdate();
                }
            }

            // Step 4: mark service_usage as billed
            if (!serviceUsageIds.isEmpty()) {
                String inClause = serviceUsageIds.stream()
                    .map(String::valueOf).collect(java.util.stream.Collectors.joining(","));
                String markSvcSql = "UPDATE service_usage SET billed=1, bill_id=? WHERE usage_id IN (" + inClause + ")";
                try (PreparedStatement markSt = connection.prepareStatement(markSvcSql)) {
                    markSt.setInt(1, newBillId);
                    markSt.executeUpdate();
                }
            }

            connection.commit();
            return newBillId;

        } catch (SQLException e) {
            e.printStackTrace();
            try { connection.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
        } finally {
            try { connection.setAutoCommit(true); } catch (SQLException e) { e.printStackTrace(); }
        }
        return -1;
    }

    // Backward-compat 2-arg overload
    public int insertBillWithItems(Bill bill, List<BillItem> items) {
        return insertBillWithItems(bill, items,
            java.util.Collections.emptyList(), java.util.Collections.emptyList());
    }

    // ==============================
    // UPDATE STATUS ONLY
    // ==============================
    public void updateStatus(int billId, String status) {
        String sql = "UPDATE bill SET status = ? WHERE bill_id = ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setString(1, status);
            st.setInt(2, billId);
            st.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // ==============================
    // MAP RESULTSET -> BILL ITEM
    // ==============================
    private BillItem mapBillItem(ResultSet rs) throws SQLException {
        BillItem item = new BillItem();
        item.setBillItemId(rs.getInt("bill_item_id"));
        item.setBillId(rs.getInt("bill_id"));
        item.setCategoryId(rs.getInt("category_id"));
        item.setDescription(rs.getString("description"));
        item.setQuantity(rs.getBigDecimal("quantity"));
        item.setUnitPrice(rs.getBigDecimal("unit_price"));
        try { item.setSourceType(rs.getString("source_type")); } catch (SQLException ignored) {}
        try {
            int sid = rs.getInt("source_id");
            if (!rs.wasNull()) item.setSourceId(sid);
        } catch (SQLException ignored) {}
        return item;
    }

    // ==============================
    // GET BILLS PAST DUE DATE (for overdue scheduler)
    // ==============================
    public List<Bill> getPendingBillsPastDue(LocalDate today) {
        List<Bill> list = new ArrayList<>();
        String sql = "SELECT b.*, r.room_number "
                   + "FROM bill b "
                   + "JOIN contract c ON b.contract_id = c.contract_id "
                   + "JOIN room r ON c.room_id = r.room_id "
                   + "WHERE b.status = 'pending' AND b.due_date < ? AND b.is_deleted = 0";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setDate(1, Date.valueOf(today));
            ResultSet rs = st.executeQuery();
            while (rs.next()) {
                Bill b = mapBill(rs);
                b.setRoomNumber(rs.getString("room_number"));
                list.add(b);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    // ==============================
    // GET BILLS DUE IN N DAYS (for reminder notifications)
    // ==============================
    public List<Bill> getBillsDueInDays(int days) {
        List<Bill> list = new ArrayList<>();
        LocalDate target = LocalDate.now().plusDays(days);
        String sql = "SELECT b.*, r.room_number "
                   + "FROM bill b "
                   + "JOIN contract c ON b.contract_id = c.contract_id "
                   + "JOIN room r ON c.room_id = r.room_id "
                   + "WHERE b.status = 'pending' AND b.due_date = ? AND b.is_deleted = 0";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setDate(1, Date.valueOf(target));
            ResultSet rs = st.executeQuery();
            while (rs.next()) {
                Bill b = mapBill(rs);
                b.setRoomNumber(rs.getString("room_number"));
                list.add(b);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    // ==============================
    // CREATE FIRST BILL (pro-rata based on actual move-in date)
    // Called when a new contract is created mid-month.
    // Calculates rent proportional to days stayed in the first month.
    // Creates a bill with ONE item: pro-rated room rent.
    // ==============================
    public int createFirstMonthBill(int contractId, BigDecimal monthlyRent, LocalDate contractStartDate) {
        int year = contractStartDate.getYear();
        int month = contractStartDate.getMonthValue();
        int dayOfMonth = contractStartDate.getDayOfMonth();
        int daysInMonth = contractStartDate.lengthOfMonth();

        // Days actually stayed in first month = total days - start day + 1
        int daysStayed = daysInMonth - dayOfMonth + 1;

        // Pro-rata rent for first month
        BigDecimal dailyRate = monthlyRent.divide(BigDecimal.valueOf(daysInMonth), 10, java.math.RoundingMode.HALF_UP);
        BigDecimal firstMonthRent = dailyRate.multiply(BigDecimal.valueOf(daysStayed)).setScale(0, java.math.RoundingMode.HALF_UP);

        // Period = contract start date (normalized to 1st of month for DB constraint)
        LocalDate period = LocalDate.of(year, month, 1);
        LocalDate dueDate = contractStartDate.plusDays(10);

        // Skip if bill already exists for this contract + period
        if (existsByContractAndPeriod(contractId, period)) {
            return -1;
        }

        // Get ROOM_RENT category ID
        int roomCategoryId = 1; // default fallback
        try (PreparedStatement st = connection.prepareStatement(
                "SELECT category_id FROM price_category WHERE code = 'ROOM_RENT'")) {
            ResultSet rs = st.executeQuery();
            if (rs.next()) roomCategoryId = rs.getInt("category_id");
        } catch (SQLException ignored) {}

        // Build bill with one pro-rated room rent item
        Bill bill = new Bill();
        bill.setContractId(contractId);
        bill.setPeriod(period);
        bill.setDueDate(dueDate);
        bill.setTotalAmount(firstMonthRent);
        bill.setStatus("pending");

        BillItem rentItem = new BillItem();
        rentItem.setCategoryId(roomCategoryId);
        rentItem.setDescription("Tien phong " + daysStayed + " ngay ("
            + dayOfMonth + "/" + month + "/" + year + " - "
            + daysInMonth + "/" + month + "/" + year + ")");
        rentItem.setQuantity(BigDecimal.ONE);
        rentItem.setUnitPrice(firstMonthRent);
        rentItem.setSourceType("contract");

        List<BillItem> items = new ArrayList<>();
        items.add(rentItem);

        // Use the existing insertBillWithItems transaction (with empty utility/service ID lists)
        return insertBillWithItems(bill, items,
            java.util.Collections.emptyList(), java.util.Collections.emptyList());
    }

}
