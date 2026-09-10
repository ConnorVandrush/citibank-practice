import { createSlice } from "@reduxjs/toolkit";

export const AppSlice = createSlice({
  name: "app",
  initialState: {
    currentWindow: "loginWindow"
  },
  reducers: {
    setCurrentWindow: (state, action) => {
      state.currentWindow = action.payload;
    },
  },
});

export const { setCurrentWindow } = AppSlice.actions;
export const AppSliceReducer = AppSlice.reducer;