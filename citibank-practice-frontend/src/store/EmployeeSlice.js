import { createSlice } from "@reduxjs/toolkit";

export const EmployeeSlice = createSlice({
  name: "employee",
  initialState: {
    employeeId: null,
    employeeEmail: null,
    managerId: null,
    employeeExpenses: [],
  },
  reducers: {
    setEmployeeInfo: (state, action) => {
      state.employeeId = action.payload.employeeId;
      state.employeeEmail = action.payload.employeeEmail;
      state.managerId = action.payload.managerId;
      state.employeeExpenses = action.payload.employeeExpenses;
    },
  },
});

export const { setEmployeeInfo } = EmployeeSlice.actions;
export const EmployeeSliceReducer = EmployeeSlice.reducer;
