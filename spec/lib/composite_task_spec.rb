require 'composite_task'

RSpec.describe CompositeTask do
  context '#initialize' do
    let(:block_action) { proc { true } }
    shared_examples :common_initialize do
      it { is_expected.to have_attributes(io: STDOUT) }
      it 'has empty sub tasks' do
        expect(subject.sub_tasks).to be_empty
      end
    end
    shared_examples :no_block_action do
      it { is_expected.to have_attributes(action: nil) }
    end
    shared_examples :block_action do
      it { is_expected.to have_attributes(action: block_action) }
    end
    context 'anonymous top level task' do
      subject { described_class.new }
      include_examples :common_initialize
      include_examples :no_block_action
      context 'action block given' do
        subject { described_class.new(&block_action) }
        it 'raises' do
          expect{subject}.to raise_error(ArgumentError, /Anonymous tasks are only allowed without a block/)
        end
      end
    end
    context 'named top level task' do
      let(:name) { 'name' }
      shared_examples :task_name do
        it { is_expected.to have_attributes(name: name) }
      end
      context 'without action block' do
        include_examples :common_initialize
        include_examples :no_block_action
        include_examples :task_name
        subject { described_class.new(name) }
      end
      context 'with action block' do
        subject { described_class.new(name, &block_action) }
        include_examples :common_initialize
        include_examples :block_action
        include_examples :task_name
      end
    end
  end
end
