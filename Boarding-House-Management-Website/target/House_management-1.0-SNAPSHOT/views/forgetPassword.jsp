<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Forgot Password - AKDD House</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <style>
        /* 1. Import Font Pretendard */
        @import url("https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/static/pretendard.min.css");

        /* 2. Ocean Palette Variables */
        :root {
            --ocean-900: #03045E;
            --ocean-800: #023E8A;
            --ocean-700: #0077B6;
            --ocean-600: #0096C7;
            --ocean-500: #00B4D8;
            --ocean-400: #48CAE4;
            --ocean-300: #90E0EF;
            --ocean-200: #ADE8F4;
            --ocean-100: #CAF0F8;
            --ds-bg: #f4f7f9;
            --ds-text: #292A2D;
        }

        * { box-sizing: border-box; margin: 0; padding: 0; }

        body {
            font-family: 'Pretendard', sans-serif !important;
            background-color: var(--ds-bg);
            background-image: radial-gradient(circle at top right, var(--ocean-100), transparent 40%),
                              radial-gradient(circle at bottom left, var(--ocean-200), transparent 40%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--ds-text);
            padding: 20px;
        }

        .fp-card {
            background: #fff;
            border-radius: 24px;
            border: none;
            box-shadow: 0 10px 40px rgba(0,0,0,.06);
            width: 100%;
            max-width: 480px;
            padding: 3rem 2.5rem;
            animation: slideUp .4s ease both;
        }
        @keyframes slideUp {
            from { opacity: 0; transform: translateY(20px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        .brand-icon {
            width: 72px; height: 72px;
            background: var(--ocean-100); color: var(--ocean-800);
            border-radius: 20px; display: flex; align-items: center; justify-content: center;
            margin: 0 auto 1.25rem; font-size: 2rem;
        }

        .fp-title { font-size: 1.6rem; font-weight: 800; color: var(--ocean-900); letter-spacing: -0.5px; }

        /* ── Step Indicator ── */
        .step-wrapper {
            display: flex; align-items: center; justify-content: center; gap: 8px; margin-bottom: 2rem;
        }
        .step-badge {
            width: 32px; height: 32px; border-radius: 50%;
            display: inline-flex; align-items: center; justify-content: center;
            font-weight: 800; font-size: 14px; transition: all 0.3s ease;
        }
        .step-active { background: var(--ocean-700); color: white; box-shadow: 0 4px 10px rgba(0, 119, 182, 0.3); }
        .step-done { background: var(--ocean-100); color: var(--ocean-800); border: 1px solid var(--ocean-300); }
        .step-inactive { background: #f3f4f6; color: #9ca3af; }
        .step-label { font-size: .8rem; font-weight: 600; color: #6b7280; }
        .step-line { width: 16px; height: 2px; background: #e5e7eb; border-radius: 2px; }

        /* ── Inputs ── */
        .form-label { font-weight: 700; font-size: .85rem; color: #374151; margin-bottom: .4rem; }
        
        .input-icon-wrap { position: relative; margin-bottom: 1.25rem; }
        .input-icon-wrap .icon-left {
            position: absolute; top: 50%; left: 16px;
            transform: translateY(-50%);
            color: #9ca3af; pointer-events: none; font-size: 1rem;
        }
        .input-icon-wrap input {
            padding-left: 2.8rem;
            border: 1.5px solid #e5e7eb;
            border-radius: 12px;
            font-size: .95rem;
            height: 48px;
            transition: border-color .2s, box-shadow .2s;
            width: 100%;
        }
        .input-icon-wrap input:focus {
            border-color: var(--ocean-500);
            box-shadow: 0 0 0 3px rgba(0, 180, 216, 0.15);
            outline: none;
        }

        .btn-eye {
            position: absolute; top: 50%; right: 12px;
            transform: translateY(-50%);
            background: none; border: none;
            color: #9ca3af; cursor: pointer; font-size: 1.1rem;
            padding: 4px; line-height: 1;
        }
        .btn-eye:hover { color: var(--ocean-600); }

        /* ── OTP Input ── */
        .otp-input {
            letter-spacing: 1rem; font-size: 2.2rem; font-weight: 800;
            text-align: center; color: var(--ocean-900);
            border: 2px solid #e5e7eb; border-radius: 16px;
            height: 72px; width: 100%; transition: all .2s;
            font-family: 'Pretendard', sans-serif;
        }
        .otp-input:focus {
            border-color: var(--ocean-500);
            box-shadow: 0 0 0 4px rgba(0, 180, 216, 0.15);
            outline: none;
        }

        /* ── Buttons ── */
        .btn-submit {
            width: 100%; height: 50px;
            background: linear-gradient(135deg, var(--ocean-800), var(--ocean-600));
            border: none; border-radius: 12px;
            color: #fff; font-weight: 700; font-size: 1rem;
            cursor: pointer; transition: transform .2s, box-shadow .2s;
            display: flex; align-items: center; justify-content: center; gap: .5rem;
        }
        .btn-submit:hover  { transform: translateY(-2px); box-shadow: 0 6px 16px rgba(0, 119, 182, 0.25); color: #fff; }
        .btn-submit:active { transform: scale(.98); }

        /* ── Alerts ── */
        .server-error {
            background: #fef2f2; border: 1px solid #fecaca; border-radius: 12px;
            padding: 1rem; display: flex; align-items: center; gap: .75rem;
            color: #b91c1c; font-size: .9rem; font-weight: 600; margin-bottom: 1.5rem;
        }
        .info-box {
            background: #f0fdf4; border: 1px solid #bbf7d0; border-radius: 12px;
            padding: 1rem; color: #166534; font-size: .9rem; font-weight: 600;
            display: flex; align-items: center; gap: .75rem; margin-bottom: 1.5rem;
        }

        .switch-link { font-size: .9rem; color: #64748b; text-align: center; margin-top: 1.5rem; }
        .switch-link a { color: var(--ocean-700); font-weight: 700; text-decoration: none; transition: color 0.2s; }
        .switch-link a:hover { color: var(--ocean-900); text-decoration: underline; }
    </style>
</head>

<body>

    <div class="fp-card">

        <div class="text-center mb-4">
            <div class="brand-icon">
                <i class="bi bi-shield-lock-fill"></i>
            </div>
            <h3 class="fp-title">Forgot Password</h3>
        </div>

        <%-- Step indicator --%>
        <div class="step-wrapper">
            <span class="step-badge ${phase == 1 ? 'step-active' : 'step-done'}">
                <c:choose><c:when test="${phase > 1}"><i class="bi bi-check"></i></c:when><c:otherwise>1</c:otherwise></c:choose>
            </span>
            <span class="step-label ${phase >= 1 ? 'text-dark' : ''}">Email</span>
            
            <div class="step-line ${phase >= 2 ? 'bg-primary' : ''}"></div>
            
            <span class="step-badge ${phase == 2 ? 'step-active' : (phase > 2 ? 'step-done' : 'step-inactive')}">
                <c:choose><c:when test="${phase > 2}"><i class="bi bi-check"></i></c:when><c:otherwise>2</c:otherwise></c:choose>
            </span>
            <span class="step-label ${phase >= 2 ? 'text-dark' : ''}">OTP</span>
            
            <div class="step-line ${phase == 3 ? 'bg-primary' : ''}"></div>
            
            <span class="step-badge ${phase == 3 ? 'step-active' : 'step-inactive'}">3</span>
            <span class="step-label ${phase == 3 ? 'text-dark' : ''}">Reset</span>
        </div>

        <%-- Alerts --%>
        <c:if test="${not empty error}">
            <div class="server-error">
                <i class="bi bi-exclamation-triangle-fill fs-5"></i>
                <span>${error}</span>
            </div>
        </c:if>
        <c:if test="${not empty info}">
            <div class="info-box">
                <i class="bi bi-info-circle-fill fs-5"></i>
                <span>${info}</span>
            </div>
        </c:if>

        <%-- ========== PHASE 1: Enter email ========== --%>
        <c:if test="${phase == 1}">
            <p class="text-muted small text-center mb-4" style="line-height: 1.5; font-size: .9rem;">
                Enter your registered email address. We will send a 6-digit OTP to your inbox.
            </p>

            <form action="${pageContext.request.contextPath}/auth" method="post">
                <input type="hidden" name="action" value="verifyReset">

                <div class="mb-4">
                    <label class="form-label">Registered Email</label>
                    <div class="input-icon-wrap">
                        <i class="bi bi-envelope-fill icon-left"></i>
                        <input type="email" name="email" placeholder="Enter your email address" required autofocus>
                    </div>
                </div>

                <button type="submit" class="btn-submit">
                    <i class="bi bi-send-fill"></i> Send OTP
                </button>
            </form>
        </c:if>

        <%-- ========== PHASE 2: Enter OTP ========== --%>
        <c:if test="${phase == 2}">
            <div class="text-center mb-4">
                <p class="text-muted small" style="line-height: 1.6; font-size: .9rem;">
                    An OTP code has been sent to<br>
                    <strong style="color: var(--ocean-900); font-size: 1rem;">${maskedEmail}</strong><br>
                    The code is valid for <strong style="color: var(--ocean-700);">5 minutes</strong>.
                </p>
            </div>

            <form action="${pageContext.request.contextPath}/auth" method="post" id="otpForm">
                <input type="hidden" name="action" value="verifyOtp">

                <div class="mb-4">
                    <label class="form-label text-center d-block" style="color: var(--ocean-800);">Enter OTP Code</label>
                    <input type="text" name="otp" id="otpInput" class="otp-input"
                           placeholder="------"
                           maxlength="6" pattern="[0-9]{6}"
                           inputmode="numeric" autocomplete="one-time-code"
                           required autofocus>
                    <div class="form-text text-center mt-3 small text-muted">Check your Spam folder if you do not see the email.</div>
                </div>

                <button type="submit" class="btn-submit">
                    <i class="bi bi-shield-fill-check fs-5"></i> Verify OTP
                </button>
            </form>

            <div class="switch-link">
                Didn't receive the code? 
                <a href="${pageContext.request.contextPath}/auth?action=forgetPassword">Resend OTP</a>
            </div>
        </c:if>

        <%-- ========== PHASE 3: Set new password ========== --%>
        <c:if test="${phase == 3}">
            <div class="info-box mb-4">
                <i class="bi bi-check-circle-fill fs-5"></i>
                <span>OTP verified! Please set your new password.</span>
            </div>

            <form action="${pageContext.request.contextPath}/auth" method="post">
                <input type="hidden" name="action" value="doResetPassword">

                <div class="mb-3">
                    <label class="form-label">New Password</label>
                    <div class="input-icon-wrap">
                        <i class="bi bi-lock-fill icon-left"></i>
                        <input type="password" name="newPassword" id="newPassword" 
                               placeholder="At least 6 characters" required autofocus>
                        <button class="btn-eye" type="button" onclick="togglePassword('newPassword','eyeNew')">
                            <i class="bi bi-eye" id="eyeNew"></i>
                        </button>
                    </div>
                </div>

                <div class="mb-4">
                    <label class="form-label">Confirm New Password</label>
                    <div class="input-icon-wrap">
                        <i class="bi bi-shield-lock-fill icon-left"></i>
                        <input type="password" name="confirmPassword" id="confirmPassword" 
                               placeholder="Re-enter new password" required>
                        <button class="btn-eye" type="button" onclick="togglePassword('confirmPassword','eyeConfirm')">
                            <i class="bi bi-eye" id="eyeConfirm"></i>
                        </button>
                    </div>
                </div>

                <button type="submit" class="btn-submit">
                    <i class="bi bi-key-fill"></i> Reset Password
                </button>
            </form>
        </c:if>

        <div class="text-center mt-4">
            <a href="${pageContext.request.contextPath}/auth?action=login"
               class="text-decoration-none fw-semibold" style="color: #6b7280; font-size: .9rem; transition: color .2s;">
                <i class="bi bi-arrow-left me-1"></i> Back to Login
            </a>
        </div>

    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function togglePassword(inputId, iconId) {
            var input = document.getElementById(inputId);
            var icon  = document.getElementById(iconId);
            if (input.type === 'password') {
                input.type = 'text';
                icon.classList.replace('bi-eye', 'bi-eye-slash');
            } else {
                input.type = 'password';
                icon.classList.replace('bi-eye-slash', 'bi-eye');
            }
        }

        // Auto-submit when 6 digits entered
        var otpInput = document.getElementById('otpInput');
        if (otpInput) {
            otpInput.addEventListener('input', function () {
                this.value = this.value.replace(/[^0-9]/g, '');
                if (this.value.length === 6) {
                    this.closest('form').submit();
                }
            });
        }
    </script>
</body>
</html>