package Controllers;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.UUID;

@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,
    maxFileSize = 5 * 1024 * 1024,
    maxRequestSize = 10 * 1024 * 1024
)
public class ImageUploadServlet extends HttpServlet {

    private static final String UPLOAD_DIR_ROOM   = "assets/images/room";
    private static final String UPLOAD_DIR_SERVICE = "assets/images/service";
    private static final String UPLOAD_DIR_USER    = "assets/images/user";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String type = request.getParameter("type");
        if (type == null || type.isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\":\"Missing type parameter\"}");
            return;
        }

        Part filePart = request.getPart("image");
        if (filePart == null || filePart.getSize() == 0) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\":\"No file uploaded\"}");
            return;
        }

        String contentType = filePart.getContentType();
        if (contentType == null || !contentType.startsWith("image/")) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\":\"Only image files are allowed\"}");
            return;
        }

        String uploadDir;
        switch (type) {
            case "room":
                uploadDir = UPLOAD_DIR_ROOM;
                break;
            case "service":
                uploadDir = UPLOAD_DIR_SERVICE;
                break;
            case "user":
                uploadDir = UPLOAD_DIR_USER;
                break;
            default:
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"error\":\"Invalid type. Use: room, service, user\"}");
                return;
        }

        String fileName = UUID.randomUUID().toString() + getFileExtension(filePart.getContentType());
        String uploadPath = getServletContext().getRealPath("/") + uploadDir;

        Path uploadDirPath = Paths.get(uploadPath);
        if (!Files.exists(uploadDirPath)) {
            Files.createDirectories(uploadDirPath);
        }

        Path filePath = uploadDirPath.resolve(fileName);
        try (InputStream input = filePart.getInputStream()) {
            Files.copy(input, filePath, StandardCopyOption.REPLACE_EXISTING);
        }

        String relativePath = uploadDir + "/" + fileName;
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.getWriter().write("{\"path\":\"" + fileName + "\",\"fullPath\":\"" + relativePath.replace("\\", "\\\\") + "\"}");
    }

    private String getFileExtension(String contentType) {
        switch (contentType) {
            case "image/png":
                return ".png";
            case "image/gif":
                return ".gif";
            case "image/webp":
                return ".webp";
            default:
                return ".jpg";
        }
    }
}
