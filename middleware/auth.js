const jwt = require("jsonwebtoken");

function protect(req, res, next) {
    const token = req.cookies && req.cookies.token;
    // Also support Authorization: Bearer <token> as a fallback
    const bearer = req.headers.authorization;
    const authToken = bearer && bearer.startsWith("Bearer ")
        ? bearer.split(" ")[1]
        : null;

    const selected = token || authToken;

    if (!selected) {
        return res.status(401).json({ message: "Not authorized, please log in" });
    }

    try {
        const decoded = jwt.verify(selected, process.env.JWT_SECRET);
        req.user = { id: decoded.id, email: decoded.email };
        next();
    } catch (err) {
        return res.status(401).json({ message: "Session expired, please log in again" });
    }
}

module.exports = { protect };