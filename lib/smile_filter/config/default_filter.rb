# frozen_string_literal: false

#  UserFilter.#exec が定義されると、rbファイルのフィルターが
#  txtファイルのフィルターに先立って処理されるようになります。
#  例として、これより下の行の`#'を削除すると、
#  一度でもshitaかつbigでコメントしたユーザーの全てのコメントを
#  nakaかつblackかつsmallに変更します。

module SmileFilter
  module UserFilter
    module_function
  # def exec(chats)
  #   black_list = chats.each_with_object([]) do |chat, ids|
  #                if chat.position?(:shita) && chat.size?(:big)
  #                   ids << chat.user_id
  #                 end
  #               end
  #   black_list.uniq!
  #   chats.each do |chat|
  #     next unless black_list.include?(chat.user_id)
  #     chat.position = :naka
  #     chat.color = :black
  #     chat.site = :small
  #   end
  # end
  end
end
