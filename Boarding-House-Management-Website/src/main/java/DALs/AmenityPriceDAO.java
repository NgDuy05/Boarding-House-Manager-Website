package DALs;

import Utils.DBContext;
import java.math.BigDecimal;
import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * DAO for amenity_price table — monthly surcharges per amenity.
 * Each room's amenities contribute fixed monthly amounts to the bill.
 */
public class AmenityPriceDAO extends DBContext {

    /**
     * Get current monthly price for an amenity as of a given date.
     * Returns ZERO if no price configured.
     */
    public BigDecimal getCurrentPrice(int amenityId, LocalDate asOfDate) {
        String sql = "SELECT TOP 1 monthly_amount FROM amenity_price "
                   + "WHERE amenity_id = ? AND effective_from <= ? "
                   + "ORDER BY effective_from DESC";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, amenityId);
            st.setDate(2, Date.valueOf(asOfDate));
            ResultSet rs = st.executeQuery();
            if (rs.next()) return rs.getBigDecimal("monthly_amount");
        } catch (SQLException e) { e.printStackTrace(); }
        return BigDecimal.ZERO;
    }

    /**
     * Get all amenities for a room with their current monthly prices.
     * Returns list of maps with keys: amenityId, amenityName, monthlyAmount.
     * Amenities with price = 0 are still included (admin may have configured 0 = included free).
     */
    public List<Map<String, Object>> getAmenitiesWithPriceForRoom(int roomId, LocalDate asOfDate) {
        List<Map<String, Object>> result = new ArrayList<>();
        String sql = "SELECT a.amenity_id, a.amenity_name, "
                   + "ISNULL(ap.monthly_amount, 0) AS monthly_amount "
                   + "FROM room_amenity ra "
                   + "JOIN amenity a ON ra.amenity_id = a.amenity_id "
                   + "LEFT JOIN amenity_price ap ON ap.amenity_id = a.amenity_id "
                   + "  AND ap.effective_from = ("
                   + "    SELECT TOP 1 effective_from FROM amenity_price "
                   + "    WHERE amenity_id = a.amenity_id AND effective_from <= ? "
                   + "    ORDER BY effective_from DESC"
                   + "  ) "
                   + "WHERE ra.room_id = ? AND a.is_deleted = 0";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setDate(1, Date.valueOf(asOfDate));
            st.setInt(2, roomId);
            ResultSet rs = st.executeQuery();
            while (rs.next()) {
                Map<String, Object> row = new LinkedHashMap<>();
                row.put("amenityId",     rs.getInt("amenity_id"));
                row.put("amenityName",   rs.getString("amenity_name"));
                row.put("monthlyAmount", rs.getBigDecimal("monthly_amount"));
                result.add(row);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return result;
    }
}
