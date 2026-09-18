import { useDispatch } from "react-redux";
import { setCurrentWindow } from "../../store/AppSlice";
import { setEmployeeInfo } from "../../store/EmployeeSlice";
import { socket } from "../../socket/socket.js";
import styles from "./LoginComponent.module.css";

export default function LoginComponent() {
  const dispatch = useDispatch();

  function handleLogin(event) {
    event.preventDefault();

    const email = document.getElementById("username").value;
    const password = document.getElementById("password").value;

    (async () => {
      try {
        const loginResponse = await fetch("/auth/login", {
          method: "POST",
          body: JSON.stringify({
            email: email,
            password: password,
          }),
          headers: {
            "Content-Type": "application/json",
          },
        }).then((res) => res.json());

        if (!loginResponse.access_token) {
          alert("Login failed. Please check your credentials.");
          return;
        }

        const token = loginResponse.access_token;

        localStorage.setItem("token", token);

        // Connect to Socket.IO using the JWT
        socket.auth = {
          token: token,
        };

        socket.connect();

        const {
          employeeID,
          email: employeeEmail,
          managerID,
          expenses,
        } = await fetch(`/employees/${loginResponse.user_id}`, {
          method: "GET",
          headers: {
            "Content-Type": "application/json",
            Authorization: `Bearer ${token}`,
          },
        }).then((res) => res.json());

        dispatch(
          setEmployeeInfo({
            employeeId: employeeID,
            email: employeeEmail,
            managerId: managerID,
            employeeExpenses: expenses,
          }),
        );

        dispatch(setCurrentWindow("employeeWindow"));
      } catch (error) {
        console.error("Login error:", error);
        alert("Login failed. Please try again.");
      }
    })();
  }

  return (
    <div className={styles.loginComponent}>
      <div className={styles.loginCard}>
        <div className={styles.loginCardHeader}>
          <h3>CORNERSTONE BANK</h3>
          <p>INTERNAL SYSTEMS</p>
        </div>
        <div className={styles.loginCardBody}>
          <h1>BUSINESS EXPENSES DASHBOARD</h1>
          <p>
            Centralized visibility into corporate spend, vendor payments, and
            budget utilization across all business units.
          </p>
        </div>
        <div className={styles.loginCardFooter}>
          <p>CLASSIFIED — AUTHORIZED PERSONNEL ONLY</p>
        </div>
      </div>
      <div className={styles.loginForm}>
        <div className={styles.loginFormDiv}>
          <h1>Sign in to your account</h1>
          <p>Enter your employee credentials to access the expenses portal.</p>
          <form className={styles.loginFormInner}>
            <label htmlFor="username">EMPLOYEE EMAIL</label>
            <input type="text" id="username" name="username" />
            <label htmlFor="password">PASSWORD</label>
            <input type="password" id="password" name="password" />
            <button type="submit" onClick={handleLogin}>
              Login
            </button>
          </form>
        </div>
      </div>
    </div>
  );
}
