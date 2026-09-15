import { useSelector } from "react-redux";

import styles from "./EmployeeComponent.module.css";

export default function EmployeeComponent() {
  const employeeEmail = useSelector((state) => state.employee.employeeEmail);

  return (
    <div className={styles.employeeComponent}>
      <h1>Welcome, {employeeEmail}</h1>
      {/* Employee component content goes here */}
    </div>
  );
}
