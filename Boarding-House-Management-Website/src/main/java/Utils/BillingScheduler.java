package Utils;

import DALs.BillDAO;
import DALs.ContractDAO;
import DALs.NotificationDAO;
import Models.Bill;
import Models.Contract;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

import java.time.LocalDate;
import java.time.LocalTime;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.util.List;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

/**
 * Daily scheduler running at 8 AM Asia/Saigon:
 *   1. Marks overdue bills (pending + past due_date → overdue)
 *   2. Sends due-date reminders (3 days before)
 *   3. Sends contract expiry reminders (30 days and 7 days before)
 */
@WebListener
public class BillingScheduler implements ServletContextListener {

    private ScheduledExecutorService executor;

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        executor = Executors.newSingleThreadScheduledExecutor(r -> {
            Thread t = new Thread(r, "BillingScheduler");
            t.setDaemon(true);
            return t;
        });

        long initialDelay = secondsUntil8AM();
        executor.scheduleAtFixedRate(this::runDailyTasks, initialDelay, 86400L, TimeUnit.SECONDS);

        System.out.println("[BillingScheduler] Started. Next run in " + initialDelay + "s");
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        if (executor != null) {
            executor.shutdownNow();
        }
    }

    // ==============================
    // MAIN DAILY JOB
    // ==============================
    private void runDailyTasks() {
        System.out.println("[BillingScheduler] Running daily tasks at " + LocalDate.now());
        try {
            BillDAO         billDAO     = new BillDAO();
            ContractDAO     contractDAO = new ContractDAO();
            NotificationDAO notifDAO    = new NotificationDAO();
            LocalDate       today       = LocalDate.now();

            markOverdueBills(billDAO, notifDAO, today);
            sendDueDateReminders(billDAO, notifDAO, today);
            sendExpiryReminders(contractDAO, notifDAO, today);

        } catch (Exception e) {
            System.err.println("[BillingScheduler] Error in daily task: " + e.getMessage());
            e.printStackTrace();
        }
    }

    // ==============================
    // 1. MARK OVERDUE
    // ==============================
    private void markOverdueBills(BillDAO billDAO, NotificationDAO notifDAO, LocalDate today) {
        List<Bill> overdue = billDAO.getPendingBillsPastDue(today);
        for (Bill b : overdue) {
            billDAO.updateStatus(b.getBillId(), "overdue");
            String title   = "Hóa đơn quá hạn thanh toán";
            String content = "Hóa đơn phòng " + b.getRoomNumber()
                    + " kỳ " + b.getPeriod().getMonthValue() + "/" + b.getPeriod().getYear()
                    + " đã quá hạn từ " + b.getDueDate() + ". Vui lòng thanh toán ngay.";
            notifDAO.insertForContract(b.getContractId(), title, content);
        }
        if (!overdue.isEmpty()) {
            System.out.println("[BillingScheduler] Marked " + overdue.size() + " bills as overdue");
        }
    }

    // ==============================
    // 2. DUE DATE REMINDERS (3 days before)
    // ==============================
    private void sendDueDateReminders(BillDAO billDAO, NotificationDAO notifDAO, LocalDate today) {
        List<Bill> upcoming = billDAO.getBillsDueInDays(3);
        for (Bill b : upcoming) {
            String title   = "Nhắc nhở: hóa đơn sắp đến hạn";
            String content = "Hóa đơn phòng " + b.getRoomNumber()
                    + " kỳ " + b.getPeriod().getMonthValue() + "/" + b.getPeriod().getYear()
                    + " sẽ đến hạn vào ngày " + b.getDueDate() + ".";
            notifDAO.insertForContract(b.getContractId(), title, content);
        }
    }

    // ==============================
    // 3. CONTRACT EXPIRY REMINDERS (30 and 7 days before)
    // ==============================
    private void sendExpiryReminders(ContractDAO contractDAO, NotificationDAO notifDAO, LocalDate today) {
        for (int days : new int[]{30, 7}) {
            List<Contract> expiring = contractDAO.getContractsExpiringInDays(days);
            for (Contract c : expiring) {
                String title   = "Hợp đồng sắp hết hạn";
                String content = "Hợp đồng phòng " + c.getRoomNumber()
                        + " sẽ hết hạn sau " + days + " ngày (ngày " + c.getEndDate() + "). "
                        + "Vui lòng liên hệ để gia hạn.";
                notifDAO.insertForContract(c.getContractId(), title, content);
            }
        }
    }

    // ==============================
    // COMPUTE SECONDS UNTIL NEXT 8 AM (Asia/Saigon)
    // ==============================
    private long secondsUntil8AM() {
        ZoneId      zone  = ZoneId.of("Asia/Saigon");
        ZonedDateTime now  = ZonedDateTime.now(zone);
        ZonedDateTime next8 = now.toLocalDate().atTime(LocalTime.of(8, 0)).atZone(zone);
        if (!now.isBefore(next8)) {
            next8 = next8.plusDays(1);
        }
        return java.time.Duration.between(now, next8).getSeconds();
    }
}
