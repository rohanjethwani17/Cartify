require 'rails_helper'

RSpec.describe ProductPolicy do
  let(:store) { create(:store) }
  let(:other_store) { create(:store) }
  let(:user) { create(:user) }
  let(:product) { create(:product, store: store) }
  let(:other_product) { create(:product, store: other_store) }
  
  subject { described_class.new(context, product) }
  
  let(:context) { { current_user: user, current_store: store } }
  
  context 'as owner' do
    before { create(:store_membership, :owner, store: store, user: user) }
    
    it { expect(subject.show?).to be true }
    it { expect(subject.create?).to be true }
    it { expect(subject.update?).to be true }
    it { expect(subject.destroy?).to be true }
  end
  
  context 'as staff' do
    before { create(:store_membership, store: store, user: user, role: 'staff') }
    
    it { expect(subject.show?).to be true }
    it { expect(subject.create?).to be true }
    it { expect(subject.update?).to be true }
    it { expect(subject.destroy?).to be false }
  end
  
  context 'as read_only' do
    before { create(:store_membership, :read_only, store: store, user: user) }
    
    it { expect(subject.show?).to be true }
    it { expect(subject.create?).to be false }
    it { expect(subject.update?).to be false }
    it { expect(subject.destroy?).to be false }
  end
  
  context 'not a member' do
    it { expect(subject.show?).to be false }
    it { expect(subject.create?).to be false }
    it { expect(subject.update?).to be false }
    it { expect(subject.destroy?).to be false }
  end
  
  context 'product from another store' do
    let(:context) { { current_user: user, current_store: store } }
    
    before { create(:store_membership, :owner, store: store, user: user) }
    
    subject { described_class.new(context, other_product) }
    
    it { expect(subject.show?).to be false }
    it { expect(subject.update?).to be false }
    it { expect(subject.destroy?).to be false }
  end
end
