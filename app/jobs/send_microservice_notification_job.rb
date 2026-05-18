class SendMicroserviceNotificationJob < ApplicationJob
  queue_as :default

  # Sidekiq sẽ tự động gọi hàm perform này khi đến lượt nó xử lý trong hàng đợi
  def perform(order_id, customer_email, total_amount)
    url = "http://localhost:3001/v1/send_email"

    payload = {
      order_id: order_id,
      email: customer_email,
      amount: total_amount.to_f
    }

    # Bắn HTTP POST sang Notification Service
    response = Faraday.post(url, payload.to_json, { "Content-Type" => "application/json" })

    if response.status == 200
      puts "🎉 [SIDEKIQ] Đã xử lý ngầm thành công đơn hàng ##{order_id}"
    else
      # Nếu service kia lỗi (500, 404...), raise lỗi ở đây để Sidekiq biết và tự động RETRY lại sau.
      raise "Microservice trả về lỗi hình như sập rồi: #{response.status}"
    end
  end
end
