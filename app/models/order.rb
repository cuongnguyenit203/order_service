class Order < ApplicationRecord
  # Sau khi lưu DB thành công, đẩy tác vụ vào hàng đợi Sidekiq ngay lập tức
  after_create :async_notify_microservice

  private

  def async_notify_microservice
    # Hàm .perform_later sẽ đẩy các tham số này vào Redis thành 1 queue công việc
    SendMicroserviceNotificationJob.perform_later(self.id, self.customer_email, self.total_amount)

    puts "🚀 [Hệ thống Đơn hàng] Đã đẩy đơn hàng vào hàng đợi Sidekiq. Khách hàng có thể tiếp tục lướt web!"
  end
end
