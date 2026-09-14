const jwt = require("jsonwebtoken");

const JWT_SECRET = process.env.JWT_SECRET;
const JWT_EXPIRES_IN = process.env.JWT_EXPIRES_IN || "7d";

const COOKIE_OPTIONS = {
    httpOnly: true,
    sameSite: "lax",
    secure: process.env.NODE_ENV === "production",
    maxAge: 7 * 24 * 60 * 60 * 1000 // 7 days
};

function signToken(user) {
    return jwt.sign(
        { id: user.id, email: user.email },
        JWT_SECRET,
        { expiresIn: JWT_EXPIRES_IN }
    );
}

function setAuthCookie(res, user) {
    res.cookie("token", signToken(user), COOKIE_OPTIONS);
}

function clearAuthCookie(res) {
    res.clearCookie("token", {
        httpOnly: true,
        sameSite: "lax",
        secure: process.env.NODE_ENV === "production"
    });
}

function sanitizeUser(row) {
    return {
        id: row.id,
        firstName: row.first_name,
        lastName: row.last_name,
        email: row.email
    };
}

module.exports = {
    COOKIE_OPTIONS,
    signToken,
    setAuthCookie,
    clearAuthCookie,
    sanitizeUser
};