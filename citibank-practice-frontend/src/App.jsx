import { useSelector } from "react-redux";

import LoginComponent from "./components/login/LoginComponent";
import EmployeeComponent from "./components/employee/EmployeeComponent";

export default function App() {
  const currentWindow = useSelector((state) => state.app.currentWindow);

  const renderCurrentWindow = () =>
    ({
      loginWindow: <LoginComponent />,
      employeeWindow: <EmployeeComponent />,
    })[currentWindow];

  return <div>{renderCurrentWindow()}</div>;
}
