package Controllers;

import DALs.*;
import Models.*;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.*;

/**
 * AJAX endpoint: GET /bill/preview?contractId=X&period=YYYY-MM
 * Returns JSON array of pre-filled bill item previews.
 * Used by createBill.jsp to auto-populate the bill items table.
 */
@WebServlet("/bill/preview")
public class BillPreviewServlet extends HttpServlet {

    private ContractDAO     contractDAO;
    private RoomDAO         roomDAO;
    private FacilityDAO     facilityDAO;
    private AmenityPriceDAO amenityPriceDAO;
    private UtilityDAO      utilityDAO;
    private ServiceDAO      serviceDAO;
    private PriceDAO        priceDAO;

    @Override
    public void init() {
        contractDAO     = new ContractDAO();
        roomDAO         = new RoomDAO();
        facilityDAO     = new FacilityDAO();
        amenityPriceDAO = new AmenityPriceDAO();
        utilityDAO      = new UtilityDAO();
        serviceDAO      = new ServiceDAO();
        priceDAO        = new PriceDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");

        try {
            String contractIdStr = request.getParameter("contractId");
            String periodStr     = request.getParameter("period");

            if (contractIdStr == null || periodStr == null) {
                response.setStatus(400);
                response.getWriter().write("{\"error\":\"contractId and period required\"}");
                return;
            }

            int       contractId  = Integer.parseInt(contractIdStr);
            LocalDate periodStart = parsePeriod(periodStr);
            LocalDate periodEnd   = periodStart.withDayOfMonth(periodStart.lengthOfMonth());

            List<Map<String, Object>> items = buildPreviewItems(contractId, periodStart, periodEnd);

            response.getWriter().write(toJson(items));

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(500);
            response.getWriter().write("{\"error\":\"" + e.getMessage() + "\"}");
        }
    }

    private List<Map<String, Object>> buildPreviewItems(
            int contractId, LocalDate periodStart, LocalDate periodEnd) {

        List<Map<String, Object>> items = new ArrayList<>();

        Contract contract = contractDAO.getById(contractId);
        if (contract == null) return items;

        Room room = roomDAO.getRoomById(contract.getRoomId());
        if (room == null) return items;

        LocalDate contractStart = contract.getStartDate();
        int roomCategoryId = priceDAO.getCategoryIdByCode("ROOM_RENT");

        // Check if this is the first bill period (contract starts mid-month)
        boolean isFirstPeriod = contractStart != null
            && contractStart.getYear() == periodStart.getYear()
            && contractStart.getMonthValue() == periodStart.getMonthValue()
            && contractStart.getDayOfMonth() > 1;

        BigDecimal monthlyRent = room.getBasePrice() != null ? room.getBasePrice() : BigDecimal.ZERO;

        // 1. Room rent (pro-rata for first month if mid-month start)
        if (isFirstPeriod) {
            int startDay = contractStart.getDayOfMonth();
            int daysInMonth = periodStart.lengthOfMonth();
            int daysStayed = daysInMonth - startDay + 1;
            BigDecimal dailyRate = monthlyRent.divide(BigDecimal.valueOf(daysInMonth), 10, java.math.RoundingMode.HALF_UP);
            BigDecimal proratedRent = dailyRate.multiply(BigDecimal.valueOf(daysStayed)).setScale(0, java.math.RoundingMode.HALF_UP);
            items.add(buildItem(
                "room", null, roomCategoryId,
                "Tien phong " + daysStayed + " ngay ("
                    + startDay + "/" + periodStart.getMonthValue() + " - "
                    + daysInMonth + "/" + periodStart.getMonthValue() + ")",
                BigDecimal.ONE, proratedRent
            ));
        } else {
            items.add(buildItem(
                "room", null, roomCategoryId,
                "Tien phong " + room.getRoomNumber()
                    + " thang " + periodStart.getMonthValue() + "/" + periodStart.getYear(),
                BigDecimal.ONE, monthlyRent
            ));
        }

        // 2. Facility surcharges from room_facility (pro-rata for first month if mid-month start)
        int facilityCategoryId = priceDAO.getCategoryIdByCode("AMENITY");
        List<Map<String, Object>> facItems =
            facilityDAO.getFacilitiesWithPriceForRoom(room.getRoomId());
        for (Map<String, Object> fac : facItems) {
            BigDecimal monthly = (BigDecimal) fac.get("monthlyPrice");
            if (monthly == null || monthly.compareTo(BigDecimal.ZERO) <= 0) continue;
            int qty = (int) fac.get("quantity");
            if (isFirstPeriod) {
                int startDay = contractStart.getDayOfMonth();
                int daysInMonth = periodStart.lengthOfMonth();
                int daysStayed = daysInMonth - startDay + 1;
                BigDecimal dailyRate = monthly.divide(BigDecimal.valueOf(daysInMonth), 10, java.math.RoundingMode.HALF_UP);
                BigDecimal prorated = dailyRate.multiply(BigDecimal.valueOf(daysStayed)).setScale(0, java.math.RoundingMode.HALF_UP);
                items.add(buildItem(
                    "amenity", (Integer) fac.get("facilityId"), facilityCategoryId,
                    "Phu phi " + fac.get("facilityName") + " ("
                        + daysStayed + " ngay)",
                    BigDecimal.ONE, prorated
                ));
            } else {
                items.add(buildItem(
                    "amenity", (Integer) fac.get("facilityId"), facilityCategoryId,
                    "Phu phi " + fac.get("facilityName")
                        + (qty > 1 ? " x" + qty : "")
                        + " thang " + periodStart.getMonthValue() + "/" + periodStart.getYear(),
                    BigDecimal.valueOf(qty), monthly
                ));
            }
        }

        // 3. Utility consumption (electricity, water, etc.)
        List<UtilityUsage> usages = utilityDAO.getUnbilledByRoomAndPeriod(room.getRoomId(), periodStart);
        for (UtilityUsage uu : usages) {
            BigDecimal rate = utilityDAO.getPriceAtDate(uu.getUtilityId(), periodStart);
            int consumption = uu.getConsumption();
            if (consumption <= 0) continue;
            BigDecimal cons = BigDecimal.valueOf(consumption);
            int utilCatId = priceDAO.getCategoryIdByUtilityName(uu.getUtilityName());
            if (utilCatId <= 0) utilCatId = priceDAO.getCategoryIdByCode("ELECTRICITY");
            items.add(buildItem(
                "utility", uu.getUsageId(), utilCatId,
                uu.getUtilityName() + ": " + uu.getOldValue() + " -> " + uu.getNewValue()
                    + " = " + consumption + " " + uu.getUnit() + " x " + rate.toPlainString() + "d",
                cons, rate
            ));
        }

        // 4. Approved unbilled services in period
        List<ServiceUsage> services =
            serviceDAO.getUnbilledApprovedByContractAndPeriod(contractId, periodStart, periodEnd);
        for (ServiceUsage su : services) {
            BigDecimal price = su.getUnitPrice() != null ? su.getUnitPrice() : BigDecimal.ZERO;
            int svcCatId = priceDAO.getCategoryIdByCode("SERVICE");
            items.add(buildItem(
                "service", su.getUsageId(), svcCatId,
                su.getServiceName() + " x " + su.getQuantity() + " (ngay " + su.getUsageDate() + ")",
                su.getQuantity(), price
            ));
        }

        return items;
    }

    /** Build a preview item map. sourceId=null for room/amenity rows without a specific source row. */
    private Map<String, Object> buildItem(String sourceType, Integer sourceId,
            int categoryId, String description, BigDecimal qty, BigDecimal unitPrice) {
        Map<String, Object> item = new LinkedHashMap<>();
        item.put("sourceType",  sourceType);
        item.put("sourceId",    sourceId);
        item.put("categoryId",  categoryId);
        item.put("description", description);
        item.put("quantity",    qty.toPlainString());
        item.put("unitPrice",   unitPrice.toPlainString());
        item.put("lineTotal",   qty.multiply(unitPrice).toPlainString());
        return item;
    }

    /** Serialize list of maps to JSON string without external libraries. */
    private String toJson(List<Map<String, Object>> items) {
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < items.size(); i++) {
            if (i > 0) sb.append(",");
            sb.append("{");
            Map<String, Object> m = items.get(i);
            boolean first = true;
            for (Map.Entry<String, Object> e : m.entrySet()) {
                if (!first) sb.append(",");
                first = false;
                sb.append("\"").append(e.getKey()).append("\":");
                Object v = e.getValue();
                if (v == null) sb.append("null");
                else if (v instanceof Number) sb.append(v);
                else if (v instanceof Boolean) sb.append(v);
                else sb.append("\"").append(String.valueOf(v).replace("\\", "\\\\").replace("\"", "\\\"")).append("\"");
            }
            sb.append("}");
        }
        sb.append("]");
        return sb.toString();
    }

    private LocalDate parsePeriod(String value) {
        // Accept "YYYY-MM" or "YYYY-MM-DD"
        if (value.length() == 7) return LocalDate.parse(value + "-01");
        return LocalDate.parse(value).withDayOfMonth(1);
    }
}
