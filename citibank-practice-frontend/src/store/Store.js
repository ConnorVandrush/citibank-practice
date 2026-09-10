import { configureStore } from "@reduxjs/toolkit";
import { AppSliceReducer } from "./AppSlice";

export const Store = configureStore({
  reducer: {
    app: AppSliceReducer,
  },
  middleware: (getDefault) => getDefault(),
});

export default Store;
