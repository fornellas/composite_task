require 'composite_task'

RSpec.describe CompositeTask do
  context '#initialize' do
    let(:block_action) { proc { true } }
    shared_examples :common_initialize do
      it 'has no sub tasks' do
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
  context '#add_sub_task' do
    context 'add task directly' do
      let(:sub_task) { described_class.new }
      it 'adds task' do
        expect do
          subject.add_sub_task(sub_task)
        end.to change{ subject.sub_tasks.include?(sub_task) }
          .from(be_falsey)
          .to(be_truthy)
      end
    end
    context 'add task by attributes' do
      let(:sub_task_name) { 'sub_task_name' }
      let(:sub_task_block) { proc {} }
      def added_sub_task ; subject.sub_tasks.first ; end
      it 'creates and adds task' do
        expect do
          subject.add_sub_task(sub_task_name, &sub_task_block)
        end.to change{ subject.sub_tasks.length }
          .from(0)
          .to(1)
        expect(added_sub_task.name).to eq(sub_task_name)
        expect(added_sub_task.action).to eq(sub_task_block)
      end
    end
  end
  context '#add_group' do
    let(:group_name) { 'group_name' }
    def added_group ; subject.sub_tasks.first ; end
    it 'adds empty sub task' do
      expect do
        subject.add_group(group_name) { }
      end.to change{ subject.sub_tasks.length }
        .from(0)
        .to(1)
      expect(added_group.name).to eq(group_name)
      expect(added_group.action).to be_nil
    end
    it 'yields created task' do
      yielded_group = nil
      subject.add_group(group_name) { |group| yielded_group = group }
      expect(yielded_group).to eq(added_group)
      expect(yielded_group.name).to eq(group_name)
      expect(yielded_group.action).to be_nil
      expect(yielded_group).to be_a(described_class)
    end
  end
  context '#execute' do
    # TODO
  end
  context '#leaf?' do
    context 'no sub tasks' do
      subject { described_class.new.leaf? }
      it 'returns true' do
        expect(subject).to be_truthy
      end
    end
    context 'with sub tasks' do
      subject do
        composite_task = described_class.new
        composite_task.add_sub_task('sub-task'){}
        composite_task.leaf?
      end
      it 'returns false' do
        expect(subject).to be_falsey
      end
    end
  end
  context '#length' do
    subject do
      ct = described_class.new('top level'){}
      ct.add_group('group') do |g|
        g.add_sub_task('task inside group'){}
      end
      ct
    end
    let(:tasks_with_action) { 2 }
    it 'returns number of tasks with action' do
      expect(subject.length).to eq(tasks_with_action)
    end
  end
  context '#tasks' do
    # TODO
  end
  context '#has_action?' do
    context 'has action' do
      subject { described_class.new('test'){}.has_action? }
      it 'returns true' do
        expect(subject).to be_truthy
      end
    end
    context 'has no action' do
      subject { described_class.new('test').has_action? }
      it 'returns true' do
        expect(subject).to be_falsey
      end
    end
  end
  context '#tasks_with_action' do
    # TODO
  end
  context '#empty?' do
    # TODO
  end
  context '#[]' do
    # TODO
  end
  context '#call_action' do
    # TODO
  end
end
