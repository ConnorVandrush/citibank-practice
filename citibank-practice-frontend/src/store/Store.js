import { CustomeMiddleware } from "./CustomMiddleware.js";
import { configureStore } from "@reduxjs/toolkit";
import { AppSliceReducer } from "./AppSlice";
import { EmployeeSliceReducer } from "./EmployeeSlice";

export const Store = configureStore({
  reducer: {
    app: AppSliceReducer,
    employee: EmployeeSliceReducer,
  },
  middleware: (getDefault) => getDefault().concat(CustomeMiddleware),
});

export default Store;
