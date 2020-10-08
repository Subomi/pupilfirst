class ResolveEmbedCodeMutator < ApplicationQuery
  include AuthorizeAuthor
  property :content_block_id, validates: { presence: true }

  # add last_resolved_at
  # validate 1 min
  def resolve
    content_block.update!(
      content: { url: content_block.content['url'], request_source: content_block.content['request_source'], embed_code: embed_code },
    )
  end

  private

  def embed_code
    @embed_code ||= ::Oembed::Resolver.new(origin_url).embed_code
  rescue ::Oembed::Resolver::ProviderNotSupported
    nil
  end

  def origin_url
    url = content_block&.content['url'] # rubocop:disable Lint/SafeNavigationChain

    return url if url.present?

    raise "Unable to find url for content block #{content_block_id}"
  end

  def content_block
    @content_block ||= ContentBlock.find_by(id: content_block_id)
  end

  def resource_school
    content_block&.target_version&.target&.course&.school
  end
end
