describe Travis::API::V3::Queries::BuildPermissions do
  let(:user) { FactoryBot.create(:user) }

  subject { described_class.new({}, 'BuildPermissions') }

  describe '#find_for_repo' do
    let(:repo) { FactoryBot.create(:repository) }
    let!(:permission) { repo.permissions.create(build: true, user: user) }

    it 'returns permissions for repo' do
      perms = subject.find_for_repo(repo)

      expect(perms.first.build).to eq(true)
      expect(perms.first.user.id).to eq(user.id)
    end

    context 'when permission has user_id: nil' do
      let!(:permission) { repo.permissions.create(build: true, user_id: nil) }

      it 'filters it out' do
        perms = subject.find_for_repo(repo)
        expect(perms.length).to eq(0)
      end
    end
  end

  describe '#find_for_organization' do
    let(:organization) { FactoryBot.create(:org) }

    let!(:membership) { organization.memberships.create(user: user, role: 'admin', build_permission: true) }

    it 'returns build memberships for organization' do
      perms = subject.find_for_organization(organization)

      expect(perms.first.build_permission).to eq(true)
      expect(perms.first.user.id).to eq(user.id)
    end

    context 'when membership has user_id: nil' do
      let!(:membership) { organization.memberships.create(user_id: nil, role: 'admin', build_permission: true) }

      it 'filters it out' do
        perms = subject.find_for_organization(organization)
        expect(perms.length).to eq(0)
      end
    end
  end

  describe '#update_for_repo' do
    let(:repo) { FactoryBot.create(:repository) }

    before { repo.permissions.create(build: true, user: user) }

    it 'updates build permissions' do
      expect(subject.update_for_repo(repo, [user.id], false)).to eq(1)
      expect(repo.permissions.first.build).to eq(false)
    end
  end

  describe '#update_for_organization' do
    let(:organization) { FactoryBot.create(:org) }

    before { organization.memberships.create(user: user, role: 'admin', build_permission: true) }

    it 'updates build permissions' do
      expect(subject.update_for_organization(organization, [user.id], false)).to eq(1)
      expect(organization.memberships.first.build_permission).to eq(false)
    end
  end
end
