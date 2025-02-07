import React, { useState, useEffect } from "react";
import axios from "axios";
import "./Browse.css";
import Sidebar from "../../../Components/User/Sidebar/Sidebar";
import { useNavigate } from "react-router-dom";
import { IoMdSend } from "react-icons/io";
import { TextField } from "@mui/material";
import { RadioGroup, FormControlLabel, Radio } from "@mui/material";

function Browse() {
  const [sortBy, setSortBy] = useState("Assigned");
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [modalContent, setModalContent] = useState(null);
  const [templates, setTemplates] = useState([]);
  const [items, setItems] = useState([]);
  const [selectedDate, setSelectedDate] = useState("");
  const [openedId, SetOpenedID] = useState();

  const navigate = useNavigate();

  useEffect(() => {
    const token = localStorage.getItem("token");
    if (!token) {
      console.error("Token is missing. Please log in.");
      navigate("/login");
      return;
    }

    const fetchTemplates = async () => {
      try {
        const response = await axios.get(
          `${process.env.REACT_APP_BACKEND_SERVER_URL}/template/getTemplates`,
          {
            headers: {
              Authorization: `Bearer ${token}`,
            },
          }
        );
        setTemplates(response.data.templates);
      } catch (error) {
        console.error("Error fetching templates:", error);
      }
    };

    fetchTemplates();
  }, [navigate]);

  const handleView = async (tag_id) => {
    try {
      const token = localStorage.getItem("token");
      SetOpenedID(tag_id);
      const response = await axios.get(
        `${process.env.REACT_APP_BACKEND_SERVER_URL}/items/getItemsByTemplate/${tag_id}`,
        {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        }
      );
      console.log("Fetched Items:", response.data);

      const fetchedItems = response.data.map((item) => ({
        ...item,
        checklist_template_linked_items_id:
          item.ChecklistTemplateLinkedItems?.[0]?.checklist_item_id || null,
        template_version:
          item.ChecklistTemplateLinkedItems?.[0]?.template_version_id || null,
        response:
          item.input_type === "Boolean"
            ? item.response || item.input || ""
            : null,
        numberInput:
          item.input_type === "Numeric" && item.numberInput !== undefined
            ? item.numberInput
            : 0,
        comments: item.comments || "",
      }));

      setItems(fetchedItems);
      setModalContent("Items");
      setIsModalOpen(true);
    } catch (error) {
      console.error("Error fetching items:", error);
    }
  };

  const handleCloseModal = () => {
    setIsModalOpen(false);
    setModalContent(null);
    setItems([]);
  };

  const handleInputChange = (index, field, value) => {
    const updatedItems = [...items];
    updatedItems[index][field] = value;

    if (field === "response" && updatedItems[index].input_type === "Boolean") {
      updatedItems[index].input = value;
    } else if (
      field === "numberInput" &&
      updatedItems[index].input_type === "Numeric"
    ) {
      updatedItems[index].input = value || null;
    }

    console.log("Updated Items:", updatedItems);
    setItems(updatedItems);
  };

  const handleActionClick = async (index) => {
    const item = items[index];
    try {
      const token = localStorage.getItem("token");
      const dateToSubmit =
        selectedDate || new Date().toISOString().split("T")[0];

      const payload = {
        status:
          item.response === true || item.response === "Yes" ? "Yes" : "No",
        input: item.input || "",
        comments: item.comments || null,
        checklist_template_linked_items_id:
          item.checklist_template_linked_items_id,
        user_assigned_checklist_template_id: 1,
        template_version: item.template_version,
        selected_date: dateToSubmit,
      };

      console.log("Payload being sent:", payload);

      await axios.post(
        `${process.env.REACT_APP_BACKEND_SERVER_URL}/response/createResponse`,
        payload,
        {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        }
      );

      alert("Checklist submitted successfully!");
    } catch (error) {
      console.error("Error submitting checklist:", error);
      alert("Failed to submit checklist. Please try again.");
    }
  };

  const handleDateChange = (e) => {
    setSelectedDate(e.target.value);
  };

  const handleBulkSubmit = async () => {
    try {
      const token = localStorage.getItem("token");

      const userDetails = {
        username: {},
        email: "",
      };

      if (!items || items.length === 0) {
        alert("No checklist items to submit.");
        return;
      }

      const checklistTemplateId = openedId;

      if (!checklistTemplateId) {
        alert("Checklist Template ID is missing.");
        return;
      }

      const submissionPromises = items.map((item) => {
        console.log("Submitting item:", item);

        return axios.post(
          `${process.env.REACT_APP_BACKEND_SERVER_URL}/response/createResponse`,
          {
            status: item.response === true ? "Yes" : "No",

            input: item.input,
            comments: item.comments || null,
            checklist_template_linked_items_id:
              item.checklist_template_linked_items_id,
            user_assigned_checklist_template_id: 1,
            template_version: item.template_version,
            selected_date:
              selectedDate || new Date().toISOString().split("T")[0],
            response: item.input,
          },
          {
            headers: {
              Authorization: `Bearer ${token}`,
            },
          }
        );
      });
      console.log("Items before submission:", items);

      await Promise.all(submissionPromises);

      console.log("All checklist items submitted successfully!", items);

      const emailResponse = await axios.post(
        `${process.env.REACT_APP_BACKEND_SERVER_URL}/checklist/submit`,
        {
          checklistTemplateId,
          checklistItems: items,
          username: userDetails.username,
          selectedDate: selectedDate || new Date().toISOString().split("T")[0],
        },
        {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        }
      );

      console.log("Email response:", emailResponse);

      if (emailResponse.status === 200) {
        alert("Checklist submitted and email sent successfully!");
      } else {
        alert("Checklist submitted, but failed to send email.");
      }
    } catch (error) {
      console.error("Error submitting checklist:", error);
      alert("Failed to submit checklist. Please try again.");
    }
  };

  return (
    <>
      <Sidebar />
      <div className="browse-container">
        <div className="content">
          <h2 className="checklist-heading">Assigned Checklist</h2>

          <div className="main-card">
            <div className="filter-container">
              <input
                type="text"
                placeholder="Browse Checklist"
                className="search-input"
              />
              <div className="sort-container">
                <label htmlFor="sort-select">Sort by:</label>
                <select
                  id="sort-select"
                  value={sortBy}
                  onChange={(e) => setSortBy(e.target.value)}
                  className="sort-select"
                >
                  <option value="Assigned">Assigned</option>
                  <option value="Pending">Pending</option>
                  <option value="Completed">Completed</option>
                </select>
              </div>
            </div>

            <div className="card-container">
              {templates.length > 0 ? (
                templates.map((template) => (
                  <div key={template.id} className="card">
                    <h3>{template.template_name}</h3>
                    <h3
                      className="view"
                      onClick={() => handleView(template.tag_id)}
                    >
                      View
                    </h3>
                  </div>
                ))
              ) : (
                <p>No templates found</p>
              )}
            </div>
          </div>

          {isModalOpen && (
            <div className="modal">
              <div className="modal-content">
                <span className="close" onClick={handleCloseModal}>
                  &times;
                </span>

                {modalContent === "Items" && (
                  <div>
                    <button>
                      Date:{" "}
                      <input
                        type="date"
                        value={selectedDate}
                        onChange={handleDateChange}
                        className="date-picker"
                      />
                    </button>
                    <h3>Checklist Items</h3>
                    <table>
                      <thead>
                        <tr>
                          <th>S.No</th>
                          <th>Description</th>
                          <th>Response</th>
                          <th>Comments</th>
                          <th>Action</th>
                        </tr>
                      </thead>
                      <tbody>
                        {items.map((item, index) => (
                          <tr key={index}>
                            <td>{index + 1}</td>
                            <td>{item.checklist_name}</td>

                            <td>
                              {item.input_type === "Boolean" ? (
                                <RadioGroup
                                  row
                                  value={item.response || ""}
                                  onChange={(e) =>
                                    handleInputChange(
                                      index,
                                      "response",
                                      e.target.value
                                    )
                                  }
                                >
                                  <FormControlLabel
                                    value="Yes"
                                    control={<Radio />}
                                    label="Yes"
                                  />
                                  <FormControlLabel
                                    value="No"
                                    control={<Radio />}
                                    label="No"
                                  />
                                </RadioGroup>
                              ) : item.input_type === "Numeric" ? (
                                <TextField
                                  type="number"
                                  variant="outlined"
                                  size="small"
                                  value={item.numberInput || ""}
                                  onChange={(e) =>
                                    handleInputChange(
                                      index,
                                      "numberInput",
                                      e.target.value
                                    )
                                  }
                                  inputProps={{ min: 0 }}
                                />
                              ) : null}
                            </td>

                            <td>
                              <TextField
                                variant="outlined"
                                size="small"
                                value={item.comments || ""}
                                onChange={(e) =>
                                  handleInputChange(
                                    index,
                                    "comments",
                                    e.target.value
                                  )
                                }
                                placeholder="Add comments (optional)"
                              />
                            </td>
                            <td>
                              <IoMdSend
                                style={{
                                  color: "green",
                                  fontSize: "1.5rem",
                                  cursor: "pointer",
                                }}
                                onClick={() => handleActionClick(index)}
                              />
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                    <div className="submit-container">
                      <button
                        className="submit-button"
                        onClick={handleBulkSubmit}
                      >
                        Submit
                      </button>
                    </div>
                  </div>
                )}
              </div>
            </div>
          )}
        </div>
      </div>
    </>
  );
}

export default Browse;
