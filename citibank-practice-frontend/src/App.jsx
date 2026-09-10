import { useSelector } from "react-redux";

import LoginComponent from "./components/login/LoginComponent";

export default function App() {
  const currentWindow = useSelector((state) => state.app.currentWindow);

  const renderCurrentWindow = () =>
    ({
      loginWindow: <LoginComponent />,
    })[currentWindow];

  return <div>{renderCurrentWindow()}</div>;
}
