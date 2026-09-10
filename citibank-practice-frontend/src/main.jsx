import { Provider } from "react-redux";
import { createRoot } from "react-dom/client";
import App from "./App.jsx";
import Store from "./store/Store.js";

createRoot(document.getElementById("root")).render(
  <Provider store={Store}>
    <App />
  </Provider>,
);
