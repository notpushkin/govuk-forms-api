class Api::V1::PagesController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActionController::ParameterMissing, with: :missing_parameter

  def index
    render json: form.pages.to_json
  end

  def create
    new_page = form.pages.new(page_params)

    if FeatureService.enabled?(:accept_legacy_answer_types)
      convert_old_answer_types_to_new_format(new_page)
    end

    if new_page.save
      form.update!(question_section_completed: false)
      render json: { id: new_page.id }, status: :created
    else
      render json: new_page.errors.to_json, status: :bad_request
    end
  end

  def show
    if FeatureService.enabled?(:accept_legacy_answer_types)
      display_new_answer_types_in_old_format(page)
    end

    render json: page.to_json, status: :ok
  end

  def update
    page.assign_attributes(page_params)

    if FeatureService.enabled?(:accept_legacy_answer_types)
      convert_old_answer_types_to_new_format(page)
    end

    if page.save
      form.update!(question_section_completed: false)
      render json: { success: true }.to_json, status: :ok
    else
      render json: page.errors.to_json, status: :bad_request
    end
  end

  def destroy
    page.destroy!
    form.update!(question_section_completed: false)
    render json: { success: true }.to_json, status: :ok
  end

  def move_down
    page.move_lower
    render json: { success: 1 }.to_json, status: :ok
  end

  def move_up
    page.move_higher
    render json: { success: 1 }.to_json, status: :ok
  end

private

  def form
    @form ||= Form.find(params.require(:form_id))
  end

  def page
    @page ||= form.pages.find(params.require(:page_id))
  end

  def answer_settings_hash?
    # these answer_types have an answer_settings value which is a hash
    %w[selection text date address name].include? params[:answer_type]
  end

  def input_type_hash?
    # these answer_types have an input_type value which is a hash
    %w[address].include? params[:answer_type]
  end

  def answer_setting_params
    if answer_settings_hash?
      # answer_types with answer_settings must be whitelisted to pass strong params
      if input_type_hash?
        { answer_settings: [:only_one_option, { selection_options: [:name] }, { input_type: {} }] }
      else
        { answer_settings: [:input_type, :title_needed, :only_one_option, { selection_options: [:name] }] }
      end
    else
      # answer_types with answer_settings will be passed nil, so we just whitelist that
      :answer_settings
    end
  end

  def page_params
    params.require(:page).permit(
      :id,
      :question_text,
      :question_short_name,
      :hint_text,
      :answer_type,
      :next_page,
      :is_optional,
      answer_setting_params,
    )
  end

  def not_found
    render json: { error: "not_found" }.to_json, status: :not_found
  end

  def missing_parameter(exception)
    render json: { error: exception.message }, status: :bad_request
  end

  def convert_old_answer_types_to_new_format(page)
    case page.answer_type
    when "single_line"
      page.answer_settings = { input_type: "single_line" }
      page.answer_type = "text"
    when "long_text"
      page.answer_settings = { input_type: "long_text" }
      page.answer_type = "text"
    when "address"
      page.answer_settings ||= { input_type: { uk_address: "true", international_address: "false" } }
    when "date"
      page.answer_settings ||= { input_type: "other_date" }
    end
  end

  def display_new_answer_types_in_old_format(page)
    case page.answer_type
    when "text"
      page.answer_type = page.answer_settings["input_type"]
      page.answer_settings = nil
    when "date", "address"
      page.answer_settings = nil
    end
  end
end
