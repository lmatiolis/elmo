class Report::ByAnswerGrouping < Report::Grouping
  belongs_to(:question)
  
  def apply(rel)
    case question.type.name
    when "select_one"
      # get questioning ids
      qing_ids = question.questionings.collect{|qing| qing.id}.join(",")
      raise Report::ReportError.new("The question #{question.code} doesn't appear on any forms.") if qing_ids.empty?
      
      # do it!
      rel.select("aotr#{uid}.str as `#{col_name}`").
        joins("LEFT JOIN answers a#{uid} ON responses.id = a#{uid}.response_id").
        joins("LEFT JOIN options ao#{uid} ON a#{uid}.option_id = ao#{uid}.id").
        joins("LEFT JOIN translations aotr#{uid} ON " +
          "(aotr#{uid}.obj_id = ao#{uid}.id and aotr#{uid}.fld = 'name' and aotr#{uid}.class_name = 'Option' " +
            "AND aotr#{uid}.language_id = (SELECT id FROM languages WHERE code = 'eng'))").
        where("a#{uid}.questioning_id IN (#{qing_ids})").
        group("aotr#{uid}.str")
    end
  end
  
  def col_name
    question.code
  end
  
  private
    def uid
      @uid ||= 1000 + rand(8999)
    end
end