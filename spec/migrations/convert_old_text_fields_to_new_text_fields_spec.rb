require "rails_helper"
require Rails.root.join("db/migrate/20230126141136_convert_old_text_fields_to_new_text_fields.rb")

describe ConvertOldTextFieldsToNewTextFields do
  include MigrationHelpers

  let(:previous_version) { 20230126135721 }

  describe "#up" do
    before { migrate_to(previous_version) }

    it "converts existing ‘single_line‘ answer types to ‘text‘ answer types with ‘single_line‘ input types" do
      page = create(:page, answer_type: "single_line")

      described_class.new.up

      expect(page.reload.answer_type).to eq("text")
      expect(page.reload.answer_settings).to eq({ "input_type" => "single_line" })
    end

    it "converts existing ‘long_text‘ answer types to ‘text‘ answer types with ‘long_text‘ input types" do
      page = create(:page, answer_type: "long_text")

      described_class.new.up

      expect(page.reload.answer_type).to eq("text")
      expect(page.reload.answer_settings).to eq({ "input_type" => "long_text" })
    end
  end
end