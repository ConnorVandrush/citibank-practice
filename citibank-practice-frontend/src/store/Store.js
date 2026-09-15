import { configureStore } from "@reduxjs/toolkit";
import { AppSliceReducer } from "./AppSlice";
import { EmployeeSliceReducer } from "./EmployeeSlice";

export const Store = configureStore({
  reducer: {
    app: AppSliceReducer,
    employee: EmployeeSliceReducer,
  },
  middleware: (getDefault) => getDefault(),
});

export default Store;
