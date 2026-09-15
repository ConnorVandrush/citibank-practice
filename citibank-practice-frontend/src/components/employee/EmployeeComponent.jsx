import { useState } from "react";
import { useDispatch, useSelector } from "react-redux";

import { setEmployeeInfo } from "../../store/EmployeeSlice";
import styles from "./EmployeeComponent.module.css";

export default function EmployeeComponent() {
  const dispatch = useDispatch();

  const { employeeId, employeeEmail, managerId, employeeExpenses } =
    useSelector((state) => state.employee);

  const [formData, setFormData] = useState({
    amount: "",
    merchant: "",
    description: "",
    date: "",
    category: "MEALS",
  });

  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState("");
  const [success, setSuccess] = useState("");

  const handleChange = (event) => {
    const { name, value } = event.target;

    setFormData((previous) => ({
      ...previous,
      [name]: value,
    }));
  };

  const handleSubmit = async (event) => {
    event.preventDefault();

    setError("");
    setSuccess("");

    if (!employeeId) {
      setError("Employee information is not available.");
      return;
    }

    const token = localStorage.getItem("token");

    if (!token) {
      setError("You are not authenticated.");
      return;
    }

    setIsSubmitting(true);

    try {
      const response = await fetch(`/employees/${employeeId}`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify({
          expenseInfo: {
            amount: Number(formData.amount),
            merchant: formData.merchant,
            description: formData.description,
            date: formData.date,
            category: formData.category,
          },
        }),
      });

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.detail || "Failed to submit expense.");
      }

      /*
       * Add the newly-created expense to the Redux state.
       *
       * Your API returns:
       * {
       *   expenseID,
       *   employeeID,
       *   expenseInfo,
       *   status,
       *   submittedAt
       * }
       */
      dispatch(
        setEmployeeInfo({
          employeeId: employeeId,
          employeeEmail: employeeEmail,
          managerId: managerId,
          employeeExpenses: [...employeeExpenses, data],
        }),
      );

      setFormData({
        amount: "",
        merchant: "",
        description: "",
        date: "",
        category: "MEALS",
      });

      setSuccess("Expense submitted successfully.");
    } catch (err) {
      console.error("Expense submission error:", err);
      setError(err.message || "Failed to submit expense.");
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className={styles.employeeComponent}>
      <div className={styles.header}>
        <h1>Welcome, {employeeEmail}</h1>
        <p>Employee ID: {employeeId}</p>
      </div>

      <div className={styles.content}>
        {/* ==================================================
            LEFT SIDE - EXPENSES
            ================================================== */}

        <section className={styles.expensesSection}>
          <h2>My Expenses</h2>

          {employeeExpenses.length === 0 ? (
            <div className={styles.emptyState}>
              <p>You have no expenses yet.</p>
            </div>
          ) : (
            <div className={styles.expenseList}>
              {employeeExpenses.map((expense) => (
                <div className={styles.expenseCard} key={expense.expenseID}>
                  <div className={styles.expenseHeader}>
                    <h3>{expense.expenseInfo.merchant}</h3>

                    <span
                      className={`${styles.status} ${
                        styles[expense.status.toLowerCase()]
                      }`}
                    >
                      {expense.status}
                    </span>
                  </div>

                  <div className={styles.expenseAmount}>
                    ${Number(expense.expenseInfo.amount).toFixed(2)}
                  </div>

                  <div className={styles.expenseDetails}>
                    <div>
                      <strong>Category:</strong> {expense.expenseInfo.category}
                    </div>

                    <div>
                      <strong>Date:</strong> {expense.expenseInfo.date}
                    </div>

                    <div>
                      <strong>Description:</strong>{" "}
                      {expense.expenseInfo.description}
                    </div>
                  </div>

                  <div className={styles.expenseFooter}>
                    <span>
                      Submitted:{" "}
                      {new Date(expense.submittedAt).toLocaleString()}
                    </span>
                  </div>
                </div>
              ))}
            </div>
          )}
        </section>

        {/* ==================================================
            RIGHT SIDE - SUBMIT EXPENSE
            ================================================== */}

        <section className={styles.formSection}>
          <h2>Submit New Expense</h2>

          <form className={styles.expenseForm} onSubmit={handleSubmit}>
            <div className={styles.formGroup}>
              <label htmlFor="amount">Amount</label>

              <input
                id="amount"
                name="amount"
                type="number"
                step="0.01"
                min="0"
                value={formData.amount}
                onChange={handleChange}
                placeholder="0.00"
                required
              />
            </div>

            <div className={styles.formGroup}>
              <label htmlFor="merchant">Merchant</label>

              <input
                id="merchant"
                name="merchant"
                type="text"
                value={formData.merchant}
                onChange={handleChange}
                placeholder="Merchant name"
                required
              />
            </div>

            <div className={styles.formGroup}>
              <label htmlFor="category">Category</label>

              <select
                id="category"
                name="category"
                value={formData.category}
                onChange={handleChange}
                required
              >
                <option value="MEALS">Meals</option>

                <option value="LODGING">Lodging</option>

                <option value="TRANSPORTATION">Transportation</option>

                <option value="TRAVEL">Travel</option>

                <option value="OTHER">Other</option>
              </select>
            </div>

            <div className={styles.formGroup}>
              <label htmlFor="date">Expense Date</label>

              <input
                id="date"
                name="date"
                type="date"
                value={formData.date}
                onChange={handleChange}
                required
              />
            </div>

            <div className={styles.formGroup}>
              <label htmlFor="description">Description</label>

              <textarea
                id="description"
                name="description"
                value={formData.description}
                onChange={handleChange}
                placeholder="Describe the business expense"
                rows="5"
                required
              />
            </div>

            {error && <div className={styles.error}>{error}</div>}

            {success && <div className={styles.success}>{success}</div>}

            <button
              type="submit"
              disabled={isSubmitting}
              className={styles.submitButton}
            >
              {isSubmitting ? "Submitting..." : "Submit Expense"}
            </button>
          </form>
        </section>
      </div>
    </div>
  );
}
