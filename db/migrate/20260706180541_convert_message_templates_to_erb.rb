class ConvertMessageTemplatesToErb < ActiveRecord::Migration[8.1]
  TOKENS = {
    "<NOME_COMPLETO>" => "<%= nome_completo %>",
    "<TITOLO_EVENTO>" => "<%= titolo_evento %>",
    "<DATA_ORA_GRUPPO>" => "<%= data_ora_gruppo %>",
    "<NUMERO_ADULTI>" => "<%= numero_adulti %>",
    "<NUMERO_RAGAZZI>" => "<%= numero_ragazzi %>",
    "<IMPORTO_TOTALE>" => "<%= importo_totale %>"
  }.freeze

  def up
    convert(TOKENS)
  end

  def down
    convert(TOKENS.invert)
  end

  private

  def convert(replacements)
    Event.where.not(message_template: [ nil, "" ]).find_each do |event|
      template = replacements.reduce(event.message_template) { |text, (from, to)| text.gsub(from, to) }
      event.update_column(:message_template, template) if template != event.message_template
    end
  end
end
