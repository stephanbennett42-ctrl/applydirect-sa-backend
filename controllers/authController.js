const bcrypt = require("bcryptjs");
const crypto = require("crypto");
const db = require("../config/db");
const {
    setAuthCookie,
    clearAuthCookie,
    sanitizeUser
} = require("../utils/authTokens");

exports.register = (req, res) => {
    const { firstName, lastName, email, password } = req.body;

    if (!firstName || !lastName || !email || !password) {
        return res.status(400).json({ message: "All fields are required" });
    }

    if (password.length < 8) {
        return res.status(400).json({ message: "Password must be at least 8 characters long" });
    }

    const normalizedEmail = email.trim().toLowerCase();

    db.query("SELECT id FROM users WHERE email = ?", [normalizedEmail], (err, rows) => {
        if (err) {
            console.error("Register check error:", err);
            return res.status(500).json({ message: "Server error, please try again" });
        }

        if (rows.length > 0) {
            return res.status(409).json({ message: "An account with this email already exists" });
        }

        bcrypt.hash(password, 10, (err, hash) => {
            if (err) {
                console.error("Hash error:", err);
                return res.status(500).json({ message: "Server error, please try again" });
            }

            db.query(
                "INSERT INTO users (first_name, last_name, email, password) VALUES (?, ?, ?, ?)",
                [firstName.trim(), lastName.trim(), normalizedEmail, hash],
                (err, result) => {
                    if (err) {
                        console.error("Insert error:", err);
                        return res.status(500).json({ message: "Server error, please try again" });
                    }

                    const user = {
                        id: result.insertId,
                        first_name: firstName.trim(),
                        last_name: lastName.trim(),
                        email: normalizedEmail
                    };

                    setAuthCookie(res, user);

                    res.status(201).json({
                        message: "Account created successfully",
                        user: sanitizeUser(user)
                    });
                }
            );
        });
    });
};

exports.login = (req, res) => {
    const { email, password } = req.body;

    if (!email || !password) {
        return res.status(400).json({ message: "Email and password are required" });
    }

    const normalizedEmail = email.trim().toLowerCase();

    db.query("SELECT * FROM users WHERE email = ?", [normalizedEmail], (err, rows) => {
        if (err) {
            console.error("Login query error:", err);
            return res.status(500).json({ message: "Server error, please try again" });
        }

        if (rows.length === 0) {
            return res.status(401).json({ message: "Invalid email or password" });
        }

        const stored = rows[0];

        if (!stored.password) {
            return res.status(401).json({ message: "Invalid email or password. This account uses Google sign-in." });
        }

        bcrypt.compare(password, stored.password, (err, match) => {
            if (err) {
                console.error("Compare error:", err);
                return res.status(500).json({ message: "Server error, please try again" });
            }

            if (!match) {
                return res.status(401).json({ message: "Invalid email or password" });
            }

            setAuthCookie(res, stored);

            res.json({
                message: "Login successful",
                user: sanitizeUser(stored)
            });
        });
    });
};

exports.logout = (req, res) => {
    clearAuthCookie(res);
    res.json({ message: "Logged out successfully" });
};

exports.getMe = (req, res) => {
    db.query(
        "SELECT id, first_name, last_name, email FROM users WHERE id = ?",
        [req.user.id],
        (err, rows) => {
            if (err) {
                console.error("Me query error:", err);
                return res.status(500).json({ message: "Server error, please try again" });
            }

            if (rows.length === 0) {
                return res.status(404).json({ message: "User not found" });
            }

            res.json({ user: sanitizeUser(rows[0]) });
        }
    );
};

exports.forgotPassword = (req, res) => {
    const { email } = req.body;

    if (!email) {
        return res.status(400).json({ message: "Email is required" });
    }

    const normalizedEmail = email.trim().toLowerCase();
    const resetToken = crypto.randomBytes(32).toString("hex");
    const expiresAt = new Date(Date.now() + 60 * 60 * 1000); // 1 hour

    db.query(
        "UPDATE users SET reset_token = ?, reset_token_expires = ? WHERE email = ?",
        [resetToken, expiresAt, normalizedEmail],
        (err, result) => {
            if (err) {
                console.error("Reset token error:", err);
                return res.status(500).json({ message: "Server error, please try again" });
            }

            // Always return the same message; never reveal whether the email exists
            res.json({
                message: "If an account exists for that email, a password reset link has been sent"
            });
        }
    );
};

exports.resetPassword = (req, res) => {
    const { token, password } = req.body;

    if (!token || !password) {
        return res.status(400).json({ message: "Token and password are required" });
    }

    if (password.length < 8) {
        return res.status(400).json({ message: "Password must be at least 8 characters long" });
    }

    db.query(
        "SELECT id FROM users WHERE reset_token = ? AND reset_token_expires > NOW()",
        [token],
        (err, rows) => {
            if (err) {
                console.error("Reset query error:", err);
                return res.status(500).json({ message: "Server error, please try again" });
            }

            if (rows.length === 0) {
                return res.status(400).json({ message: "Invalid or expired reset token" });
            }

            bcrypt.hash(password, 10, (hashErr, hash) => {
                if (hashErr) {
                    console.error("Reset hash error:", hashErr);
                    return res.status(500).json({ message: "Server error, please try again" });
                }

                db.query(
                    "UPDATE users SET password = ?, reset_token = NULL, reset_token_expires = NULL WHERE id = ?",
                    [hash, rows[0].id],
                    (updateErr) => {
                        if (updateErr) {
                            console.error("Reset update error:", updateErr);
                            return res.status(500).json({ message: "Server error, please try again" });
                        }

                        res.json({ message: "Password reset successfully. You can now log in." });
                    }
                );
            });
        }
    );
};