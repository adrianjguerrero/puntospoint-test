module ApplicationHelper

  def log_audit(action, auditable, administrator, previous_data = nil)
    AuditLog.create(
      action: action,
      user_id: administrator.id,
      auditable_type: auditable.class.name,
      auditable_id: auditable.id,
      previous_data: previous_data,
      new_data: auditable.attributes.to_json
    )
  end
end
