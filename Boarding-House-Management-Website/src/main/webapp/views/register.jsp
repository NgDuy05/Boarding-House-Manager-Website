<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Register - AKDD House</title>
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
            min-height: 100vh;
            display: flex;
            overflow-x: hidden;
            background-color: var(--ds-bg);
            color: var(--ds-text);
        }

        .auth-panel-left {
            flex: 0 0 45%;
            background: linear-gradient(145deg, var(--ocean-900) 0%, var(--ocean-800) 50%, var(--ocean-700) 100%);
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            padding: 3rem;
            position: relative;
            overflow: hidden;
        }
        .auth-panel-left::before {
            content: ''; position: absolute;
            width: 400px; height: 400px;
            background: rgba(255,255,255,.05); border-radius: 50%;
            top: -100px; left: -100px;
        }
        .auth-panel-left::after {
            content: ''; position: absolute;
            width: 300px; height: 300px;
            background: rgba(255,255,255,.04); border-radius: 50%;
            bottom: -50px; right: -50px;
        }
        .left-inner { position: relative; z-index: 1; color: #fff; max-width: 380px; }
        .left-inner .brand-icon {
            width: 80px; height: 80px;
            background: rgba(255,255,255,.15);
            border-radius: 24px; border: 2px solid rgba(255,255,255,.3);
            display: flex; align-items: center; justify-content: center;
            margin-bottom: 1.5rem;
        }
        .left-inner h1 { font-size: 2.2rem; font-weight: 800; margin-bottom: .8rem; letter-spacing: -0.5px; }
        .left-inner p  { font-size: 1rem; opacity: .85; line-height: 1.6; margin-bottom: 2.5rem; }
        
        .steps-list { list-style: none; text-align: left; }
        .steps-list li {
            display: flex; align-items: flex-start; gap: 1rem;
            margin-bottom: 1.5rem;
        }
        .step-num {
            width: 32px; height: 32px; flex-shrink: 0;
            background: rgba(255,255,255,.15);
            border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-weight: 800; font-size: .9rem; color: rgba(255,255,255,0.7);
            border: 2px solid rgba(255,255,255,0.2);
            transition: all 0.3s ease;
        }
        .step-num.active {
            background: #fff;
            color: var(--ocean-800);
            border-color: #fff;
            box-shadow: 0 0 15px rgba(255,255,255,0.4);
        }
        .step-text { font-size: .9rem; opacity: .7; line-height: 1.5; transition: opacity 0.3s ease; }
        .step-text strong { display: block; font-weight: 700; font-size: 1rem; color: #fff; }
        li:has(.step-num.active) .step-text { opacity: 1; }

        .auth-panel-right {
            flex: 1;
            background: var(--ds-bg);
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 2rem;
            overflow-y: auto;
        }
        .auth-form-wrap {
            width: 100%;
            max-width: 500px;
            background: #fff;
            border-radius: 24px;
            padding: 3rem;
            box-shadow: 0 10px 40px rgba(0,0,0,.06);
            animation: slideUp .4s ease both;
        }
        @keyframes slideUp {
            from { opacity: 0; transform: translateY(20px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        .auth-form-wrap h2 { font-size: 1.7rem; font-weight: 800; color: var(--ocean-900); letter-spacing: -0.5px; }
        .auth-form-wrap .sub { color: #64748b; font-size: .95rem; margin-bottom: 2rem; }

        .form-label { font-weight: 700; font-size: .85rem; color: #374151; margin-bottom: .4rem; }
        .required-star { color: #ef4444; }

        .input-icon-wrap { position: relative; }
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
        .input-icon-wrap input.is-invalid { border-color: #ef4444; }
        .input-icon-wrap input.is-valid   { border-color: #10b981; }

        .btn-eye {
            position: absolute; top: 50%; right: 12px;
            transform: translateY(-50%);
            background: none; border: none;
            color: #9ca3af; cursor: pointer; font-size: 1.1rem;
            padding: 4px; line-height: 1;
        }
        .btn-eye:hover { color: var(--ocean-600); }

        .field-error { font-size: .8rem; color: #ef4444; margin-top: .4rem; font-weight: 500; display: none; }

        .row-2 { display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; }

        .server-error {
            background: #fef2f2; border: 1px solid #fecaca; border-radius: 12px;
            padding: 1rem; display: flex; align-items: center; gap: .75rem;
            color: #b91c1c; font-size: .9rem; font-weight: 500; margin-bottom: 1.5rem;
        }
        .info-box {
            background: #f0fdf4; border: 1px solid #bbf7d0; border-radius: 12px;
            padding: 1rem; color: #166534; font-size: .9rem; font-weight: 500;
            display: flex; align-items: center; gap: .75rem; margin-bottom: 1.5rem;
        }

        .btn-submit {
            width: 100%; height: 50px;
            background: linear-gradient(135deg, var(--ocean-800), var(--ocean-600));
            border: none; border-radius: 12px;
            color: #fff; font-weight: 700; font-size: 1rem;
            cursor: pointer; transition: transform .2s, box-shadow .2s;
            display: flex; align-items: center; justify-content: center; gap: .5rem;
            margin-top: 1.5rem;
        }
        .btn-submit:hover  { transform: translateY(-2px); box-shadow: 0 6px 16px rgba(0, 119, 182, 0.25); }
        .btn-submit:active { transform: scale(.98); }

        .switch-link { font-size: .9rem; color: #64748b; text-align: center; margin-top: 1.5rem; }
        .switch-link a { color: var(--ocean-700); font-weight: 700; text-decoration: none; transition: color 0.2s; }
        .switch-link a:hover { color: var(--ocean-900); text-decoration: underline; }

        /* OTP Specific */
        .otp-input-box {
            font-size: 2.2rem; font-weight: 800; letter-spacing: 1rem;
            text-align: center; border: 2px solid #e5e7eb; border-radius: 16px;
            height: 72px; width: 100%; color: var(--ocean-900);
            transition: border-color .2s, box-shadow .2s;
            font-family: 'Pretendard', sans-serif;
        }
        .otp-input-box:focus {
            border-color: var(--ocean-500);
            box-shadow: 0 0 0 4px rgba(0, 180, 216, 0.15);
            outline: none;
        }

        /* Toast */
        .toast-wrap { position: fixed; top: 24px; right: 24px; z-index: 9999; display: flex; flex-direction: column; gap: .5rem; }
        .toast-item {
            display: flex; align-items: flex-start; gap: .75rem;
            padding: 1rem 2.5rem 1rem 1.25rem; border-radius: 12px;
            box-shadow: 0 8px 30px rgba(0,0,0,.14); min-width: 300px; background: #fff;
            border-left: 4px solid #ef4444; position: relative; animation: toastIn .35s ease both;
        }
        .toast-icon  { font-size: 1.2rem; flex-shrink: 0; color: #ef4444; margin-top: 1px; }
        .toast-title { font-weight: 700; font-size: .88rem; color: #111827; line-height: 1.3; }
        .toast-msg   { font-size: .82rem; color: #6b7280; margin-top: 2px; }
        .toast-close {
            position: absolute; top: 8px; right: 10px; background: none; border: none; cursor: pointer; color: #9ca3af; font-size: .82rem;
        }
        .toast-close:hover { color: #374151; }
        .toast-progress {
            position: absolute; bottom: 0; left: 0; height: 3px; background: #ef4444; border-radius: 0 0 0 12px;
            animation: shrink 4.5s linear forwards;
        }
        @keyframes toastIn { from { opacity: 0; transform: translateX(30px); } to { opacity: 1; transform: translateX(0); } }
        @keyframes shrink { from { width: 100%; } to { width: 0; } }

        @media (max-width: 992px) {
            body { flex-direction: column; }
            .auth-panel-left { flex: none; padding: 2rem; }
            .auth-panel-left::before, .auth-panel-left::after { display: none; }
            .left-inner { max-width: 100%; text-align: center; }
            .steps-list { display: none; /* Ẩn step list trên mobile cho gọn */ }
            .left-inner .brand-icon { margin: 0 auto 1rem; width: 64px; height: 64px; font-size: 1.5rem; }
            .auth-form-wrap { padding: 2rem; }
            .row-2 { grid-template-columns: 1fr; gap: 0; }
        }
    </style>
</head>
<body>

<div class="auth-panel-left">
    <div class="left-inner">
        <div class="brand-icon">
            <i class="bi bi-buildings-fill fs-2 text-white"></i>
        </div>
        <h1>AKDD House</h1>
        <p>Create an account and start managing your rental experience seamlessly today.</p>
        <ul class="steps-list">
            <li>
                <span class="step-num ${empty phase or phase == 1 ? 'active' : ''}">1</span>
                <div class="step-text">
                    <strong>Set your credentials</strong>
                    Choose a username and a secure password
                </div>
            </li>
            <li>
                <span class="step-num ${phase == 2 ? 'active' : ''}">2</span>
                <div class="step-text">
                    <strong>Verify your email</strong>
                    Enter the OTP code sent to your inbox
                </div>
            </li>
            <li>
                <span class="step-num">3</span>
                <div class="step-text">
                    <strong>Log in and explore</strong>
                    Access all tenant features immediately
                </div>
            </li>
        </ul>
    </div>
</div>

<div class="auth-panel-right">
    <div class="auth-form-wrap">

        <c:if test="${not empty error}">
            <div class="server-error">
                <i class="bi bi-exclamation-circle-fill fs-5"></i>
                <span><c:out value="${error}" /></span>
            </div>
        </c:if>
        <c:if test="${not empty info}">
            <div class="info-box">
                <i class="bi bi-check-circle-fill fs-5"></i>
                <span><c:out value="${info}" /></span>
            </div>
        </c:if>

        <%-- ===== PHASE 1: Registration form ===== --%>
        <c:if test="${empty phase or phase == 1}">
            <h2>Create an account</h2>
            <p class="sub">Fill in the details below to get started</p>

            <form action="${pageContext.request.contextPath}/auth" method="post" id="registerForm" novalidate>
                <input type="hidden" name="action" value="sendRegisterOtp">

                <div class="mb-3">
                    <label class="form-label">Username <span class="required-star">*</span></label>
                    <div class="input-icon-wrap">
                        <i class="bi bi-person-fill icon-left"></i>
                        <input type="text" name="username" id="username" class="form-control"
                               placeholder="e.g. john_doe"
                               value="${param.username}" required
                               oninput="validateUsername(this)">
                    </div>
                    <div class="field-error" id="err-username">Username cannot be empty</div>
                </div>

                <div class="row-2 mb-3">
                    <div class="mb-3 mb-md-0">
                        <label class="form-label">Password <span class="required-star">*</span></label>
                        <div class="input-icon-wrap">
                            <i class="bi bi-lock-fill icon-left"></i>
                            <input type="password" name="password" id="password"
                                   class="form-control" placeholder="Min. 6 characters" required
                                   oninput="validatePassword(this)">
                            <button class="btn-eye" type="button" onclick="togglePwd('password','eyePwd')">
                                <i class="bi bi-eye" id="eyePwd"></i>
                            </button>
                        </div>
                        <div class="field-error" id="err-password">At least 6 characters required</div>
                    </div>
                    <div>
                        <label class="form-label">Confirm Password <span class="required-star">*</span></label>
                        <div class="input-icon-wrap">
                            <i class="bi bi-shield-lock-fill icon-left"></i>
                            <input type="password" name="confirmPassword" id="confirmPassword"
                                   class="form-control" placeholder="Re-enter password" required
                                   oninput="validateConfirm(this)">
                            <button class="btn-eye" type="button" onclick="togglePwd('confirmPassword','eyeConfirm')">
                                <i class="bi bi-eye" id="eyeConfirm"></i>
                            </button>
                        </div>
                        <div class="field-error" id="err-confirm">Passwords do not match</div>
                    </div>
                </div>

                <div class="mb-3 mt-md-2 mt-0">
                    <label class="form-label">Full Name</label>
                    <div class="input-icon-wrap">
                        <i class="bi bi-person-badge-fill icon-left"></i>
                        <input type="text" name="fullName" class="form-control"
                               placeholder="John Doe"
                               value="${param.fullName}">
                    </div>
                </div>

                <div class="row-2 mb-2">
                    <div class="mb-3 mb-md-0">
                        <label class="form-label">Email <span class="required-star">*</span></label>
                        <div class="input-icon-wrap">
                            <i class="bi bi-envelope-fill icon-left"></i>
                            <input type="email" name="email" id="emailField" class="form-control"
                                   placeholder="you@example.com"
                                   value="${param.email}" required
                                   oninput="validateEmail(this)">
                        </div>
                        <div class="field-error" id="err-email">Invalid email address</div>
                    </div>
                    <div>
                        <label class="form-label">Phone</label>
                        <div class="input-icon-wrap">
                            <i class="bi bi-telephone-fill icon-left"></i>
                            <input type="tel" name="phone" id="phoneField" class="form-control"
                                   placeholder="09xxxxxxxx"
                                   value="${param.phone}"
                                   oninput="validatePhone(this)">
                        </div>
                        <div class="field-error" id="err-phone">Invalid phone number</div>
                    </div>
                </div>

                <button type="submit" class="btn-submit mt-4">
                    <i class="bi bi-envelope-check-fill me-1"></i> Continue &amp; Verify Email
                </button>
            </form>

            <p class="switch-link">
                Already have an account?
                <a href="${pageContext.request.contextPath}/auth?action=login">Sign in</a>
            </p>
        </c:if>

        <%-- ===== PHASE 2: OTP verification ===== --%>
        <c:if test="${phase == 2}">
            <h2 class="mb-2"><i class="bi bi-envelope-paper-fill me-2" style="color: var(--ocean-500);"></i>Verify Email</h2>
            <p class="sub mb-4" style="line-height: 1.6;">
                A 6-digit OTP code was sent to <br>
                <strong style="color: var(--ocean-900); font-size: 1.05rem;">${maskedEmail}</strong><br>
                Valid for <strong style="color: var(--ocean-700);">5 minutes</strong>.
            </p>

            <form action="${pageContext.request.contextPath}/auth" method="post" id="otpForm" novalidate>
                <input type="hidden" name="action" value="verifyRegisterOtp">

                <div class="mb-4">
                    <label class="form-label" style="display:block;text-align:center;margin-bottom:.75rem; color: var(--ocean-800);">
                        Enter OTP Code
                    </label>
                    <input type="text" name="otp" id="otpInput"
                           class="otp-input-box"
                           placeholder="------"
                           maxlength="6" pattern="[0-9]{6}"
                           inputmode="numeric" autocomplete="one-time-code"
                           required autofocus>
                    <div class="field-error" id="err-otp" style="text-align:center;margin-top:.6rem;">Please enter the 6-digit code</div>
                </div>

                <button type="submit" class="btn-submit">
                    <i class="bi bi-shield-fill-check me-1 fs-5"></i> Verify &amp; Create Account
                </button>
            </form>

            <p class="switch-link" style="margin-top:1.5rem;">
                Didn't receive the code?
                <a href="${pageContext.request.contextPath}/auth?action=resendRegisterOtp">Resend OTP</a>
            </p>
            <p class="switch-link">
                <a href="${pageContext.request.contextPath}/auth?action=register">
                    <i class="bi bi-arrow-left"></i> Back to registration
                </a>
            </p>
        </c:if>

    </div>
</div>

<div class="toast-wrap" id="toastWrap"></div>

<div id="serverData"
     data-error="<c:out value='${error}' default='' />"
     style="display:none"></div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
    function togglePwd(inputId, iconId) {
        const inp  = document.getElementById(inputId);
        const icon = document.getElementById(iconId);
        if (inp.type === 'password') {
            inp.type = 'text';
            icon.classList.replace('bi-eye', 'bi-eye-slash');
        } else {
            inp.type = 'password';
            icon.classList.replace('bi-eye-slash', 'bi-eye');
        }
    }

    function setValid(input, errId, valid) {
        input.classList.toggle('is-invalid', !valid);
        input.classList.toggle('is-valid',   valid);
        const e = document.getElementById(errId);
        if (e) e.style.display = valid ? 'none' : 'block';
    }

    function validateUsername(el) { setValid(el, 'err-username', el.value.trim().length > 0); }
    function validatePassword(el) {
        setValid(el, 'err-password', el.value.length >= 6);
        const c = document.getElementById('confirmPassword');
        if (c.value) validateConfirm(c);
    }
    function validateConfirm(el) {
        setValid(el, 'err-confirm', el.value === document.getElementById('password').value && el.value.length > 0);
    }
    function validateEmail(el) {
        if (!el.value) { setValid(el, 'err-email', false); return; }
        setValid(el, 'err-email', /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(el.value));
    }
    function validatePhone(el) {
        if (!el.value) { el.classList.remove('is-invalid','is-valid'); return; }
        setValid(el, 'err-phone', /^(0|\+\d{1,3})[0-9]{8,11}$/.test(el.value.replace(/\s/g,'')));
    }

    // Phase 1 form submit validation
    var regForm = document.getElementById('registerForm');
    if (regForm) {
        regForm.addEventListener('submit', function(e) {
            const u = document.getElementById('username');
            const p = document.getElementById('password');
            const c = document.getElementById('confirmPassword');
            const em = document.getElementById('emailField');
            let ok = true;
            if (!u.value.trim())        { validateUsername(u); ok = false; }
            if (p.value.length < 6)     { validatePassword(p); ok = false; }
            if (c.value !== p.value)    { validateConfirm(c);  ok = false; }
            if (!em || !em.value || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(em.value)) {
                if (em) setValid(em, 'err-email', false);
                ok = false;
            }
            if (!ok) { e.preventDefault(); showToast('Please fix the errors above.'); }
        });
    }

    // Phase 2 OTP form submit validation
    var otpForm = document.getElementById('otpForm');
    if (otpForm) {
        otpForm.addEventListener('submit', function(e) {
            const otp = document.getElementById('otpInput');
            if (!otp.value || !/^[0-9]{6}$/.test(otp.value.trim())) {
                e.preventDefault();
                document.getElementById('err-otp').style.display = 'block';
                otp.focus();
            }
        });
        // Auto-format: only allow digits, auto-submit at 6 digits
        var otpInput = document.getElementById('otpInput');
        if (otpInput) {
            otpInput.addEventListener('input', function() {
                this.value = this.value.replace(/\D/g, '').substring(0, 6);
                document.getElementById('err-otp').style.display = 'none';
                if (this.value.length === 6) {
                    setTimeout(function() { otpForm.submit(); }, 200);
                }
            });
        }
    }

    function showToast(message) {
        const wrap = document.getElementById('toastWrap');
        const item = document.createElement('div');
        item.className = 'toast-item';

        const icon = document.createElement('i');
        icon.className = 'bi bi-exclamation-circle-fill toast-icon';

        const body = document.createElement('div');
        const titleEl = document.createElement('div');
        titleEl.className = 'toast-title';
        titleEl.textContent = 'Error';
        const msgEl = document.createElement('div');
        msgEl.className = 'toast-msg';
        msgEl.textContent = message;
        body.appendChild(titleEl);
        body.appendChild(msgEl);

        const closeBtn = document.createElement('button');
        closeBtn.className = 'toast-close';
        closeBtn.innerHTML = '<i class="bi bi-x-lg"></i>';
        closeBtn.onclick = function() { item.remove(); };

        const progress = document.createElement('div');
        progress.className = 'toast-progress';

        item.appendChild(icon);
        item.appendChild(body);
        item.appendChild(closeBtn);
        item.appendChild(progress);
        wrap.appendChild(item);
        setTimeout(function() { item.remove(); }, 4700);
    }

    document.addEventListener('DOMContentLoaded', function() {
        const err = document.getElementById('serverData').dataset.error.trim();
        if (err) showToast(err);
    });
</script>
</body>
</html>