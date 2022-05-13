require 'net/http'

class Webhooks::SlackController < ApplicationController
  include ActionView::Helpers::DateHelper
  skip_before_action :verify_authenticity_token

  def interact
    data = JSON.parse(params[:payload])
    creator_name = data["user"]["name"]
    title = data["submission"]["title"]
    description = data["submission"]["description"]
    severity = data["submission"]["severity"]
    slack_creator_id = data["user"]["id"]

    res = post_slack("conversations.create", name: title.downcase)

    slack_channel_id = JSON.parse(res.body)["channel"]["id"]

    Incident.create(
      title: title,
      description: description,
      severity: severity,
      creator_name: creator_name,
      slack_channel_id: slack_channel_id,
      slack_creator_id: slack_creator_id
    )

    res = post_slack("conversations.invite", { channel: slack_channel_id, users: slack_creator_id })

    render json: {}
  end

  def declare
    data = dialog_form(params[:trigger_id])
    post_slack("dialog.open", data)

    render json: { "status" => "ok" }
  end

  def resolve
    incident = Incident.find_by(slack_channel_id: params[:channel_id])
    if incident && incident.resolved_at
      message = "Incident already resolved"
    elsif incident && !incident.resolved_at
      incident.update(resolved_at: Time.now)
      response_time = time_ago_in_words(incident.created_at)
      message = "Incident resolved in #{response_time}"
    else
      message = "Resolve can only be used in an incident slack channel"
    end

    res = post_slack("chat.postMessage", { channel: params[:channel_id], text: message })

    render json: { "status" => "ok" }
  end

  def post_slack(api_method, data)
    Net::HTTP.post URI("https://slack.com/api/#{api_method}"),
      data.to_json,
      "Content-Type" => "application/json; charset=utf-8",
      "Authorization" => "Bearer #{Rails.application.credentials.slack_bot_token}"
  end

  private

  def dialog_form(trigger_id)
    {
      trigger_id: trigger_id,
      dialog: {
        callback_id: SecureRandom.hex,
        title: "Create an Incident",
        elements: [
          {
            type: "text",
            label: "Title",
            name: "title",
          },
          {
            type: "textarea",
            label: "Description",
            name: "description",
            optional: true
          },
          {
            type: "select",
            label: "Severity",
            name: "severity",
            optional: true,
            options: [
              { label: "High", value: "high" },
              { label: "Medium", value: "medium" },
              { label: "Low", value: "low" },
            ]
          }
        ]
      }
    }
  end
end
