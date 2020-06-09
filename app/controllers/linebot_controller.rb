class LinebotController < ApplicationController
  require 'line/bot'

  protect_from_forgery :except => [:callback]

  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end

  def callback
    body = request.body.read

    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      head :bad_request
    end

    events = client.parse_events_from(body)

    events.each { |event|
      if event.message['text'].include?("原口文仁")
        responce = "右投げ右打ち,捕手,2009年ドラフト６位,管理者の一言・・・育成枠から這い上がった「シンデレラボーイ」大腸がんを患うが克服,強打が売りの捕手で代打でも活躍。管理者の一番の推し。"
      elsif event.message['text'].include?("藤川球児")
        responce = "右投げ右打ち,投手,1998年ドラフト1位,管理者の一言・・・「火の玉ストレート」という異名があるストレートを武器とする投手、ベテランながらもその威力は健在"
      elsif event.message['text'].include?("能見篤史")
        responce = "左投げ左打ち,投手,2004年自由獲得枠,管理者の一言・・・管理者が思う「最も美しい投球フォーム」昔は先発、現在は中継ぎだがその実力はまだまだ衰えない"
      elsif event.message['text'].include?("江越大賀")
        responce = "右投げ右打ち,外野手,2014年ドラフト3位,管理者の一言・・・矢野監督からも「野人」とも称されるほどの身体能力を誇る、ただボールとバットが当たらない"
      else
        responce = "まだ未実装です、すみません"
      end
      event.image['image'].include?("甲子園")
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          message = {
            type: 'text',
            text: responce
          }
          client.reply_message(event['replyToken'], message)
        end
        when Line::Bot::Event::MessageType::Image
          image = {
            type: 'image',
            originalContentUrl:'https://gyazo.com/66d7bc9f72abcd33845917fde3a9db9d'
            previewImageUrl:'https://gyazo.com/66d7bc9f72abcd33845917fde3a9db9d'
          }
          client.reply_message(event['replyToken'], image)
        end
      end
    }

    head :ok
  end
end