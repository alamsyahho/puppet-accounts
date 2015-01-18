require 'spec_helper'

describe 'accounts::account' do
  let(:title) { 'foo' }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge({
          :puppetversion => Puppet::PUPPETVERSION,
        })
      end

      let(:pre_condition) do
        <<-EOS
class { 'accounts':
  ssh_keys => {
    foo => {
      'type'  => 'ssh-rsa',
      public  => 'FOO-S-RSA-PUBLIC-KEY',
      comment => 'foo@example.com',
    },
  },
  users    => {
    foo => {
      comment => 'Mr. Foo',
      uid     => 1000,
    },
  },
}
        EOS
      end

      context 'without param' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to have_ssh_authorized_key_resource_count(1) }
        it { is_expected.to contain_ssh_authorized_key('foo-on-foo').with({ :ensure => :present }) }
      end

      context 'when ssh_authorized_key_title => \'%{ssh_key} on %{account}\'' do
        let(:params) do
          {
            :ssh_authorized_key_title => '%{ssh_key} on %{account}',
          }
        end
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to have_ssh_authorized_key_resource_count(1) }
        it { is_expected.to contain_ssh_authorized_key('foo on foo').with({ :ensure => :present }) }
      end

      context 'when ssh_authorized_key_title => "%{ssh_keys[\'%{ssh_key}\'][\'comment\']} on %{account}"' do
        let(:params) do
          {
            :ssh_authorized_key_title => "%{ssh_keys['%{ssh_key}']['comment']} on %{account}",
          }
        end
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to have_ssh_authorized_key_resource_count(1) }
        it { is_expected.to contain_ssh_authorized_key('foo@example.com on foo').with({ :ensure => :present }) }
      end
    end
  end
end
