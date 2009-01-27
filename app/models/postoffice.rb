class Postoffice < ActionMailer::Base
  def new_order(order, to_mail)
    recipients   to_mail
    from         "noreply@theprinterdepot.net"
    headers      "Reply-to" => "noreply@theprinterdepot.net"
    subject      "Your Order at TPD - Confirmation"
    sent_on      Time.now
    content_type "text/html"

    body[:order_id] = order.id
    body[:order] = order
  end

  def confirm_order(order, to_mail)
    recipients   to_mail
    from         "noreply@theprinterdepot.net"
    headers      "Reply-to" => "noreply@theprinterdepot.net"
    subject      "Your Order at TPD - Confirmed"
    sent_on      Time.now
    content_type "text/html"

    body[:order_id] = order.id
    body[:order] = order
  end

  def shipped(order, to_mail)
    recipients   to_mail
    from         "noreply@theprinterdepot.net"
    headers      "Reply-to" => "noreply@theprinterdepot.net"
    subject      "Your Order at ThePrinterDepot has been shipped"
    sent_on      Time.now
    content_type "text/html"

    body[:order_id] = order.id
    body[:order] = order
  end

  def cancelled(order, to_mail)
    recipients   to_mail
    from         "noreply@theprinterdepot.net"
    headers      "Reply-to" => "noreply@theprinterdepot.net"
    subject      "Your Order at ThePrinterDepot was cancelled"
    sent_on      Time.now
    content_type "text/html"

    body[:order_id] = order.id
    body[:order] = order
  end

  def password_forgotten(user)
    recipients   user.email
    from         "noreply@theprinterdepot.net"
    headers      "Reply-to" => "noreply@theprinterdepot.net"
    subject      "Customer Support at The Printer Depot"
    sent_on      Time.now
    content_type "text/html"

    body[:user_id] = user.id
    body[:user] = user
  end
end
