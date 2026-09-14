const crypto = require("crypto");
const { OAuth2Client } = require("google-auth-library");
const db = require("../config/db");
const { setAuthCookie } = require("../utils/authTokens");

const CLIENT_URL = process.env.CLIENT_URL || "http://localhost:5173";
const REDIRECT_URI = process.env.GOOGLE_REDIRECT_URI || "http://localhost:5000/api/auth/google/callback";

const client = new OAuth2Client(
    process.env.GOOGLE_CLIENT_ID,
    process.env.GOOGLE_CLIENT_SECRET,
    REDIRECT_URI
);

function configured() {
    return Boolean(process.env.GOOGLE_CLIENT_ID && process.env.GOOGLE_CLIENT_SECRET);
}

exports.redirect = (req, res) => {
    if (!configured()) {
        return res.redirect(`${CLIENT_URL}/login?google=error&reason=config`);
    }

    const state = crypto.randomBytes(16).toString("hex");
    // Short-lived state cookie to prevent CSRF on the callback
    res.cookie("google_oauth_state", state, {
        httpOnly: true,
        sameSite: "lax",
        secure: process.env.NODE_ENV === "production",
        maxAge: 10 * 60 * 1000 // 10 minutes
    });

    const authUrl = client.generateAuthUrl({
        access_type: "offline",
        scope: ["profile", "email"],
        prompt: "select_account",
        state
    });

    res.redirect(authUrl);
};

exports.callback = (req, res) => {
    const failureUrl = `${CLIENT_URL}/login?google=error`;

    if (!configured()) {
        return res.redirect(failureUrl);
    }

    const { code } = req.query;
    const receivedState = req.query.state;
    const expectedState = req.cookies && req.cookies.google_oauth_state;

    if (!code || !receivedState || receivedState !== expectedState) {
        return res.redirect(failureUrl);
    }

    res.clearCookie("google_oauth_state");

    client.getToken(code)
        .then(({ tokens }) => {
            if (!tokens.id_token) {
                throw new Error("No id_token returned by Google");
            }
            return client.verifyIdToken({
                idToken: tokens.id_token,
                audience: process.env.GOOGLE_CLIENT_ID
            });
        })
        .then((ticket) => {
            const payload = ticket.getPayload();
            const googleId = payload.sub;
            const email = payload.email;
            const firstName = payload.given_name || "";
            const lastName = payload.family_name || "";

            db.query("SELECT * FROM users WHERE email = ?", [email], (err, rows) => {
                if (err) {
                    console.error("Google callback query error:", err);
                    return res.redirect(failureUrl);
                }

                if (rows.length > 0) {
                    const existing = rows[0];

                    if (!existing.google_id) {
                        db.query(
                            "UPDATE users SET google_id = ? WHERE id = ?",
                            [googleId, existing.id],
                            (linkErr) => {
                                if (linkErr) {
                                    console.error("Link google_id error:", linkErr);
                                    return res.redirect(failureUrl);
                                }
                                finalize(existing.id);
                            }
                        );
                    } else {
                        finalize(existing.id);
                    }
                } else {
                    db.query(
                        "INSERT INTO users (first_name, last_name, email, google_id) VALUES (?, ?, ?, ?)",
                        [firstName, lastName, email, googleId],
                        (insertErr, result) => {
                            if (insertErr) {
                                if (insertErr.code === "ER_DUP_ENTRY") {
                                    // Email existed but google lookup raced; try linking
                                    db.query(
                                        "UPDATE users SET google_id = ? WHERE email = ?",
                                        [googleId, email],
                                        (updErr) => {
                                            if (updErr) {
                                                console.error("Race link error:", updErr);
                                                return res.redirect(failureUrl);
                                            }
                                            db.query(
                                                "SELECT id FROM users WHERE email = ?",
                                                [email],
                                                (selErr, selRows) => {
                                                    if (selErr || selRows.length === 0) {
                                                        return res.redirect(failureUrl);
                                                    }
                                                    finalize(selRows[0].id);
                                                }
                                            );
                                        }
                                    );
                                } else {
                                    console.error("Google insert error:", insertErr);
                                    return res.redirect(failureUrl);
                                }
                            } else {
                                finalize(result.insertId);
                            }
                        }
                    );
                }
            });
        })
        .catch((err) => {
            console.error("Google callback error:", err.message);
            res.redirect(failureUrl);
        });

    function finalize(userId) {
        db.query(
            "SELECT id, first_name, last_name, email FROM users WHERE id = ?",
            [userId],
            (err, rows) => {
                if (err || rows.length === 0) {
                    console.error("Finalize lookup error:", err);
                    return res.redirect(failureUrl);
                }

                setAuthCookie(res, rows[0]);
                res.redirect(`${CLIENT_URL}/payment`);
            }
        );
    }
};

exports.demo = (req, res) => {
    const email = process.env.GOOGLE_DEMO_EMAIL || "demo.user@applydirect.co.za";
    const firstName = process.env.GOOGLE_DEMO_FIRST_NAME || "Demo";
    const lastName = process.env.GOOGLE_DEMO_LAST_NAME || "User";
    const googleId = `demo:${email}`;

    db.query("SELECT * FROM users WHERE email = ?", [email], (err, rows) => {
        if (err) {
            console.error("Demo google query error:", err);
            return res.redirect(`${CLIENT_URL}/login?google=error`);
        }

        if (rows.length > 0) {
            return finalize(rows[0].id);
        }

        db.query(
            "INSERT INTO users (first_name, last_name, email, google_id) VALUES (?, ?, ?, ?)",
            [firstName, lastName, email, googleId],
            (insertErr, result) => {
                if (insertErr) {
                    console.error("Demo google insert error:", insertErr);
                    return res.redirect(`${CLIENT_URL}/login?google=error`);
                }
                finalize(result.insertId);
            }
        );
    });

    function finalize(userId) {
        db.query(
            "SELECT id, first_name, last_name, email FROM users WHERE id = ?",
            [userId],
            (err, rows) => {
                if (err || rows.length === 0) {
                    console.error("Demo finalize error:", err);
                    return res.redirect(`${CLIENT_URL}/login?google=error`);
                }
                setAuthCookie(res, rows[0]);
                res.redirect(`${CLIENT_URL}/payment`);
            }
        );
    }
};