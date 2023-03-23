FactoryBot.define do
  factory :made_live_form do
    association :form, :with_pages, :live
    json_form_blob { form.snapshot.to_json }
  end
end
