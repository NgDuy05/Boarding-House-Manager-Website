package Utils;

/**
 * Password strength validator.
 * Checks: length >= 8, uppercase, lowercase, digit, special character.
 * Returns strength level: WEAK, MEDIUM, STRONG.
 */
public class PasswordValidator {

    public enum Strength {
        WEAK("Weak", 1),
        MEDIUM("Medium", 2),
        STRONG("Strong", 3);

        private final String label;
        private final int level;

        Strength(String label, int level) {
            this.label = label;
            this.level = level;
        }

        public String getLabel() { return label; }
        public int getLevel() { return level; }
    }

    public static class Result {
        private final Strength strength;
        private final boolean hasMinLength;
        private final boolean hasUppercase;
        private final boolean hasLowercase;
        private final boolean hasDigit;
        private final boolean hasSpecial;

        public Result(Strength strength, boolean hasMinLength, boolean hasUppercase,
                      boolean hasLowercase, boolean hasDigit, boolean hasSpecial) {
            this.strength = strength;
            this.hasMinLength = hasMinLength;
            this.hasUppercase = hasUppercase;
            this.hasLowercase = hasLowercase;
            this.hasDigit = hasDigit;
            this.hasSpecial = hasSpecial;
        }

        public Strength getStrength() { return strength; }
        public boolean hasMinLength() { return hasMinLength; }
        public boolean hasUppercase() { return hasUppercase; }
        public boolean hasLowercase() { return hasLowercase; }
        public boolean hasDigit() { return hasDigit; }
        public boolean hasSpecial() { return hasSpecial; }

        public boolean isValid() {
            return hasMinLength && hasUppercase && hasLowercase && hasDigit && hasSpecial;
        }
    }

    /**
     * Evaluate password strength.
     * @param password the raw password string (not hashed)
     * @return Result containing strength level and individual criteria
     */
    public static Result evaluate(String password) {
        if (password == null) {
            return new Result(Strength.WEAK, false, false, false, false, false);
        }

        boolean hasMinLength = password.length() >= 8;
        boolean hasUppercase = !password.equals(password.toLowerCase());
        boolean hasLowercase = !password.equals(password.toUpperCase());
        boolean hasDigit = password.matches(".*\\d.*");
        boolean hasSpecial = password.matches(".*[!@#$%^&*()_+\\-=\\[\\]{};':\"\\\\|,.<>/?].*");

        int score = 0;
        if (hasMinLength) score++;
        if (hasUppercase) score++;
        if (hasLowercase) score++;
        if (hasDigit) score++;
        if (hasSpecial) score++;

        Strength strength;
        if (score <= 2) {
            strength = Strength.WEAK;
        } else if (score <= 4) {
            strength = Strength.MEDIUM;
        } else {
            strength = Strength.STRONG;
        }

        return new Result(strength, hasMinLength, hasUppercase, hasLowercase, hasDigit, hasSpecial);
    }

    /**
     * Quick validation check - returns true if password meets all criteria.
     */
    public static boolean isValid(String password) {
        return evaluate(password).isValid();
    }
}
