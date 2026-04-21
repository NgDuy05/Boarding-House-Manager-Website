package DALs;

import Utils.DBContext;
import Models.PriceCategory;
import Models.PriceHistory;

import java.math.BigDecimal;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public class PriceDAO extends DBContext {

    // ================= GET ALL PRICE HISTORY =================
    public List<PriceHistory> getPriceHistoryByCategory(int categoryId) {

        List<PriceHistory> list = new ArrayList<>();

        String sql = "SELECT price_id, category_id, price_amount, effective_from "
                + "FROM price_history "
                + "WHERE category_id = ? "
                + "ORDER BY effective_from DESC";

        try {
            PreparedStatement st = connection.prepareStatement(sql);
            st.setInt(1, categoryId);

            ResultSet rs = st.executeQuery();

            while (rs.next()) {
                PriceHistory p = new PriceHistory();

                p.setPriceId(rs.getInt("price_id"));
                p.setCategoryId(rs.getInt("category_id"));
                p.setPriceAmount(rs.getBigDecimal("price_amount"));
                p.setEffectiveFrom(rs.getDate("effective_from").toLocalDate());

                list.add(p);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    // ================= INSERT PRICE =================
    public void insertPrice(PriceHistory price) throws Exception {
        String sql = "INSERT INTO price_history "
                + "(category_id, price_amount, effective_from) "
                + "VALUES (?, ?, ?)";

        PreparedStatement st = connection.prepareStatement(sql);

        st.setInt(1, price.getCategoryId());
        st.setBigDecimal(2, price.getPriceAmount());

        // 🔥 FIX LOGIC NGAY TẠI ĐÂY
        LocalDate input = price.getEffectiveFrom();
        LocalDate effectiveDate = input.plusMonths(1).withDayOfMonth(1);

        st.setDate(3, Date.valueOf(effectiveDate));

        int rows = st.executeUpdate();
        System.out.println("INSERT ROWS = " + rows);

        if (rows == 0) {
            throw new Exception("Insert failed, no rows affected");
        }
    }

    // ================= INSERT CATEGORY + RETURN ID =================
    public int insertCategoryReturnId(PriceCategory cat) {

        String sql = "INSERT INTO price_category (category_code, category_type, unit, is_deleted) "
                + "OUTPUT INSERTED.category_id "
                + "VALUES (?, ?, ?, 0)";

        try {
            PreparedStatement st = connection.prepareStatement(sql);

            st.setString(1, cat.getCategoryCode());
            st.setString(2, cat.getCategoryType());
            st.setString(3, cat.getUnit());

            ResultSet rs = st.executeQuery();

            if (rs.next()) {
                return rs.getInt(1);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return -1;
    }

    // ================= GET ALL CATEGORY =================
    public List<PriceCategory> getAllPriceCategories() {

        List<PriceCategory> list = new ArrayList<>();

        String sql = "SELECT category_id, category_code, category_type, unit "
                + "FROM price_category "
                + "WHERE is_deleted = 0 "
                + "ORDER BY category_type, category_code";

        try {
            PreparedStatement st = connection.prepareStatement(sql);
            ResultSet rs = st.executeQuery();

            while (rs.next()) {
                PriceCategory c = new PriceCategory();

                c.setCategoryId(rs.getInt("category_id"));
                c.setCategoryCode(rs.getString("category_code"));
                c.setCategoryType(rs.getString("category_type"));
                c.setUnit(rs.getString("unit"));

                list.add(c);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    // ================= CURRENT PRICE =================
    public BigDecimal getCurrentPrice(int categoryId) {

        String sql = "SELECT TOP 1 price_amount "
                + "FROM price_history "
                + "WHERE category_id = ? "
                + "AND effective_from <= GETDATE() "
                + "ORDER BY effective_from DESC";

        try {
            PreparedStatement st = connection.prepareStatement(sql);
            st.setInt(1, categoryId);

            ResultSet rs = st.executeQuery();

            if (rs.next()) {
                return rs.getBigDecimal("price_amount");
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return BigDecimal.ZERO;
    }

    // ================= FUTURE PRICE =================
    public BigDecimal getFuturePrice(int categoryId) {

        String sql = "SELECT TOP 1 price_amount "
                + "FROM price_history "
                + "WHERE category_id = ? "
                + "AND effective_from > GETDATE() "
                + "ORDER BY effective_from ASC";

        try {
            PreparedStatement st = connection.prepareStatement(sql);
            st.setInt(1, categoryId);

            ResultSet rs = st.executeQuery();

            if (rs.next()) {
                return rs.getBigDecimal("price_amount");
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return getCurrentPrice(categoryId);
    }

    // ================= GET CATEGORY BY ID =================
    public PriceCategory getCategoryById(int categoryId) {

        String sql = "SELECT category_id, category_code, category_type, unit "
                + "FROM price_category "
                + "WHERE category_id = ? AND is_deleted = 0";

        try {
            PreparedStatement st = connection.prepareStatement(sql);
            st.setInt(1, categoryId);

            ResultSet rs = st.executeQuery();

            if (rs.next()) {
                PriceCategory c = new PriceCategory();

                c.setCategoryId(rs.getInt("category_id"));
                c.setCategoryCode(rs.getString("category_code"));
                c.setCategoryType(rs.getString("category_type"));
                c.setUnit(rs.getString("unit"));

                return c;
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    // ================= CHECK DATE EXIST =================
    public boolean isDateExist(int categoryId, LocalDate date) {

        String sql = "SELECT COUNT(*) FROM price_history "
                + "WHERE category_id = ? AND CAST(effective_from AS DATE) = ?";
        try {
            PreparedStatement st = connection.prepareStatement(sql);
            st.setInt(1, categoryId);
            st.setDate(2, Date.valueOf(date));

            ResultSet rs = st.executeQuery();

            if (rs.next()) {
                return rs.getInt(1) > 0;
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    // ================= UPDATE PRICE =================
    public void updatePriceByDate(int categoryId, LocalDate date, BigDecimal amount) {
        String sql = "UPDATE price_history "
                + "SET price_amount = ? "
                + "WHERE category_id = ? AND effective_from = ?";

        try {
            PreparedStatement st = connection.prepareStatement(sql);
            st.setBigDecimal(1, amount);
            st.setInt(2, categoryId);
            st.setDate(3, Date.valueOf(date));
            st.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // ================= DELETE =================
    public void softDeleteCategory(int categoryId) {

        String sql = "UPDATE price_category SET is_deleted = 1 WHERE category_id = ?";

        try {
            PreparedStatement st = connection.prepareStatement(sql);
            st.setInt(1, categoryId);
            st.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
// ================= UPDATE CATEGORY =================

    public void updateCategory(PriceCategory cat) {

        String sql = "UPDATE price_category "
                + "SET category_code = ?, category_type = ?, unit = ? "
                + "WHERE category_id = ?";

        try {
            PreparedStatement st = connection.prepareStatement(sql);

            st.setString(1, cat.getCategoryCode());
            st.setString(2, cat.getCategoryType());
            st.setString(3, cat.getUnit());
            st.setInt(4, cat.getCategoryId());

            st.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // ================= NEW: UPDATE CATEGORY ONLY =================
    public void updateCategoryOnly(PriceCategory cat) {
        updateCategory(cat);
    }

    // ================= NEW: UPDATE CATEGORY + PRICE =================
    public void updateCategoryWithPrice(PriceCategory cat, BigDecimal price, LocalDate date) {

        try {
            connection.setAutoCommit(false);

            updateCategory(cat);

            if (!date.isAfter(LocalDate.now())) {
                throw new RuntimeException("Date must be future");
            }

            if (false) {
                //isDateExist(cat.getCategoryId(), date)) {
                updatePriceByDate(cat.getCategoryId(), date, price);
            } else {
                PriceHistory p = new PriceHistory();
                p.setCategoryId(cat.getCategoryId());
                p.setPriceAmount(price);
                p.setEffectiveFrom(date);
                insertPrice(p);
            }

            connection.commit();

        } catch (Exception e) {
            try {
                connection.rollback();
            } catch (Exception ex) {
            }
            e.printStackTrace();
        } finally {
            try {
                connection.setAutoCommit(true);
            } catch (Exception e) {
            }
        }
    }

    // ================= NEW: INSERT CATEGORY + PRICE =================
    public int insertCategoryWithPrice(PriceCategory cat, BigDecimal price, LocalDate date) {

        try {
            connection.setAutoCommit(false);

            if (!date.isAfter(LocalDate.now())) {
                throw new RuntimeException("Date must be future");
            }

            int categoryId = insertCategoryReturnId(cat);

            if (categoryId == -1) {
                throw new RuntimeException("Insert category failed");
            }

            PriceHistory p = new PriceHistory();
            p.setCategoryId(categoryId);
            p.setPriceAmount(price);
            p.setEffectiveFrom(date);

            insertPrice(p);

            connection.commit();

            return categoryId;

        } catch (Exception e) {
            try {
                connection.rollback();
            } catch (Exception ex) {
            }
            e.printStackTrace();
        } finally {
            try {
                connection.setAutoCommit(true);
            } catch (Exception e) {
            }
        }

        return -1;
    }

    public List<PriceCategory> getCategoriesByType(String type) {
        List<PriceCategory> list = new ArrayList<>();

        String sql = "SELECT category_id, category_code, category_type, unit "
                + "FROM price_category "
                + "WHERE is_deleted = 0 AND category_type = ? "
                + "ORDER BY category_code";

        try {
            PreparedStatement st = connection.prepareStatement(sql);
            st.setString(1, type);

            ResultSet rs = st.executeQuery();

            while (rs.next()) {
                PriceCategory c = new PriceCategory();
                c.setCategoryId(rs.getInt("category_id"));
                c.setCategoryCode(rs.getString("category_code"));
                c.setCategoryType(rs.getString("category_type"));
                c.setUnit(rs.getString("unit"));
                list.add(c);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }
    // ===============================
    // GET CATEGORY ID BY CODE (case-sensitive, not deleted)
    // ===============================

    public int getCategoryIdByCode(String code) {
        String sql = "SELECT TOP 1 category_id FROM price_category "
                + "WHERE category_code = ? AND is_deleted = 0";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setString(1, code);
            ResultSet rs = st.executeQuery();
            if (rs.next()) {
                return rs.getInt("category_id");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 1; // fallback to first category
    }

    // ===============================
    // GET CATEGORY ID BY UTILITY NAME (electricity/water mapping)
    // ===============================
    public int getCategoryIdByUtilityName(String utilityName) {
        if (utilityName == null) {
            return 0;
        }
        String normalized = utilityName.trim().toUpperCase();
        if (normalized.contains("ELECTRICITY") || normalized.contains("\u0110I\u1EC6N")) {
            return getCategoryIdByCode("ELECTRICITY");
        } else if (normalized.contains("WATER") || normalized.contains("N\u01AF\u1EDB\u0302C")) {
            return getCategoryIdByCode("WATER");
        }
        return getCategoryIdByCode("ELECTRICITY"); // fallback
    }
}
