import styles from "./LoginComponent.module.css";

export default function LoginComponent() {
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
            <button type="submit">Login</button>
          </form>
        </div>
      </div>
    </div>
  );
}
