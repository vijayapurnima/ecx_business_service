# UpdateOrganisation class, update organization from org_params

class EcxBusinessService::Profile::UpdateOrganisation
  include ExtendedInteractor

  def call
    context[:profile_failures] = []
    after_check do
      case context[:section_type]
        when 'primary_contact'
          context[:profile].assign_attributes(primary_contact_id: context[:org_params][:primary_contact_id])
          context[:profile].save!
          
        when 'account_owner'
          context[:profile].assign_attributes(account_owner_id: context[:org_params][:account_owner_id])
          context[:profile].save!

        when 'profile'

          update_categories

          if context[:org_params][:logo] &&
            context[:org_params][:logo].instance_of?(ActionDispatch::Http::UploadedFile)

            result = EcxBusinessService::Attachments::Create.call(id:              context[:profile].logo_id,
                                          attachment_type: 'Logo',
                                          file:            context[:org_params][:logo],
                                          linked_to_id:    context[:profile].legacy_id,
                                          linked_to_type:  'Organization')

            if result.success?
              context[:profile].assign_attributes(logo_id: result.attachment['id']) if context[:profile].logo_id.nil?
            else
              context.fail!(message: result.message)
            end
          end

          if context[:org_params][:capability_statement] &&
            context[:org_params][:capability_statement].instance_of?(ActionDispatch::Http::UploadedFile)
            result = EcxBusinessService::Attachments::Create.call(id:              context[:profile].capability_statement_id,
                                          attachment_type: 'capability_statement',
                                          file:            context[:org_params][:capability_statement],
                                          linked_to_id:    context[:profile].legacy_id,
                                          linked_to_type:  'Organization')

            if result.success?
              context[:profile].assign_attributes(capability_statement_id: result.attachment['id']) if context[:profile].capability_statement_id.nil?
            else
              context.fail!(message: result.message)
            end
          end

          params                               = context[:org_params].select { |p, _v| EcxBusinessService::Profile::Organisation::EDIT_PARAMS.include? p.try(:to_s) }
          context[:profile][:market_alignment] = context[:org_params][:market_alignment].try(:to_json)

          context[:profile].assign_attributes(params)

          if context[:org_params].has_key?(:new_anzsic_classification) && !context[:org_params].has_key?(:anzsic_classification)
            context[:profile].taxonomy_links.joins(:taxonomy).where('taxonomies.group_name': 'ANZSIC').delete_all
          end

          unless context[:org_params][:new_anzsic_classification].nil? || !EcxBusinessService::Taxonomy.exists?(group_name: 'ANZSIC',
                                                                                                key:        context[:org_params][:new_anzsic_classification])
            context[:profile].taxonomies << EcxBusinessService::Taxonomy.find_by(group_name: 'ANZSIC',
                                                            key:        context[:org_params][:new_anzsic_classification])
          end

          unless context[:org_params][:country_identifiers].nil? || context[:org_params][:country_identifiers].empty?
            country_identifiers_attributes = context[:org_params][:country_identifiers].map! do |ci|
              { country_id: ci[:country_id], identifier: ci[:identifier], id: ci[:id], _destroy: ci[:_destroy] }
            end
            context[:profile].assign_attributes(country_identifiers_attributes: country_identifiers_attributes)
          end

          context[:profile].save! if context[:profile].validate_data

        when 'logo'

          unless context[:org_params][:logo].nil?
            result = EcxBusinessService::Attachments::Create.call(id:              context[:profile].logo_id,
                                          attachment_type: 'Logo',
                                          file:            context[:org_params][:logo],
                                          linked_to_id:    context[:profile].legacy_id,
                                          linked_to_type:  'Organization')

            if result.success?
              context[:profile].assign_attributes(logo_id: result.attachment['id'])
              context[:profile].save!
            else
              context.fail!(message: result.message)
            end
          end

        when 'capability'
          unless context[:org_params][:capability_statement].nil?
            result = EcxBusinessService::Attachments::Create.call(id:              context[:profile].capability_statement_id,
                                          attachment_type: 'capability_statement',
                                          file:            context[:org_params][:capability_statement],
                                          linked_to_id:    context[:profile].legacy_id,
                                          linked_to_type:  'Organization')

            if result.success?
              context[:profile].assign_attributes(capability_statement_id: result.attachment['id'])
              context[:profile].save!
            else
              context.fail!(message: result.message)
            end
          end

        when 'locations'
          unless context[:org_params][:locations_attributes].nil? || context[:org_params][:locations_attributes].empty?
            context[:org_params][:locations_attributes].map! do |la|
              { location_type: la[:location_type], address: la[:address], id: la[:id], latitude: la[:latitude],
                longitude: la[:longitude], _destroy: la[:_destroy] }
            end
          end

          context[:profile].assign_attributes(context[:org_params].to_hash)

          context[:profile].save!

          EcxBusinessService::QueueBusinessForLocationsTransitionInMr.perform_later(context[:profile])

        when 'users'

          params = context[:org_params].select { |p, _v| EcxBusinessService::Profile::Organisation::EDIT_PARAMS.include? p }

          context[:profile].assign_attributes(params.to_hash)

          context[:profile].save!
        when 'certificates'
          unless context[:org_params][:certifications].nil? || context[:org_params][:certifications].empty?
            certificates = context[:org_params][:certifications]
            certificates.each do |certificate|
              if certificate[:id].nil?
                certification_context = {
                  certificate: { expiry_date: certificate[:expiry_date], certificate_type: certificate[:certificate_type],
                                attachments: certificate[:files] }, profile: context[:profile]
                }
                certification_result  = EcxBusinessService::Certification::Create.call(certification_context)
                unless certification_result.success?
                  context[:profile_failures] << { profile: context[:profile],
                                                  message: I18n.t(certification_result.message) }
                end

              elsif certificate[:destroy]
                EcxBusinessService::Certification.find(certificate[:id]).try(:destroy)
              else
                certification_context = { certificate: { id: certificate[:id], expiry_date: certificate[:expiry_date],
                                                        attachments: certificate[:files] } }
                delete_attachments(certificate[:attachments])
                certification_result  = EcxBusinessService::Certification::Update.call(certification_context)
                unless certification_result.success?
                  context[:profile_failures] << { profile: context[:profile],
                                                  message: I18n.t(certification_result.message) }
                end

              end
            end
          end
        when 'insurances'
          unless context[:org_params][:insurance_coverages].nil? || context[:org_params][:insurance_coverages].empty?
            insurances = context[:org_params][:insurance_coverages]
            insurances.each do |insurance|
              if insurance[:id].nil?
                insurance_context = {
                  insurance_coverage: { field_values: insurance[:field_values], insurance_name: insurance[:insurance_name],
                                        attachments: insurance[:files] }, profile: context[:profile]
                }
                insurance_result  = EcxBusinessService::Insurance::CreateCoverage.call(insurance_context)
                unless insurance_result.success?
                  context[:profile_failures] << { profile: context[:profile],
                                                  message: I18n.t(insurance_result.message) }
                end

              elsif insurance[:destroy]
                EcxBusinessService::InsuranceCoverage.find(insurance[:id]).try(:destroy)
              else
                insurance_context = { insurance_coverage: { id: insurance[:id], field_values: insurance[:field_values],
                                                            attachments: insurance[:files] } }
                delete_attachments(insurance[:attachments])
                insurance_result  = EcxBusinessService::Insurance::UpdateCoverage.call(insurance_context)
                unless insurance_result.success?
                  context[:profile_failures] << { profile: context[:profile],
                                                  message: I18n.t(insurance_result.message) }
                end
              end
            end
          end
        when 'tags'
          update_categories

          context[:profile].save!
        else
          context.fail!(message: 'error.required_value_missing')
        end
      # Reset the cache keys
      context[:profile].touch
      context[:profile].clear_cache
      context[:organization] = context[:profile]
    end
  end

  # check if the organization is passed to the context and an organization exists with it
  def check_context
    if !context[:profile]
      context.fail!(message: 'profile.not_exists')
    elsif !context[:org_params]
      context.fail!(message: 'profile.missing_parameters')
    end
  end

  def delete_attachments(attachments)
    attachments&.each do |attachment|
      result = EcxBusinessService::Attachments::Delete.call(id: attachment[:id])
    end
  end

  def update_categories
    unless context[:org_params][:tags_attributes].nil? || context[:org_params][:tags_attributes].empty?
      context[:org_params][:tags_attributes].each do |t|
        category        = EcxBusinessService::Category.roots.find_by(['lower(title) = ?', t[:title].downcase])
        category        = EcxBusinessService::Category.roots.find_or_create_by(title: t[:title]) if category.nil?
        t[:category_id] = category.id
      end

      context[:org_params][:tags_attributes].reject! do |e|
        (e[:id].nil? && e[:_destroy] == 'false' && context[:profile].tags_attributes.any? do |ta|
           e[:category_id] == ta[:category_id]
         end)
      end
      tags_attributes = context[:org_params][:tags_attributes]
                        .map! { |ta| { id: ta[:id], category_id: ta[:category_id], _destroy: ta[:_destroy] } }

      context[:profile].assign_attributes(tags_attributes: tags_attributes)
    end
  end
end
