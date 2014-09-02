module ComplexRepresentor
DRD_HASH = {
  href: 'http://example.com/drd/1', 
  id: 'DRD',
  doc: 'Diagnostic Repair Drones or DRDs are small robots that move around Leviathans. They are built by a Leviathan as it grows.',
  links: {
    self: 'www.example.com/drds/show/DRD',
    help: 'http://alps.io/schema.org/DRD'
  },
  attributes: {
    uuid: {
      doc: 'The UUID of the DRD.',
      profile: 'http://alps.io/schema.org/Text',
      sample: '007d8e12-babd-4f2c-b01e-8b5e2f749e1z',
      value: '007d8e12-babd-4f2c-b01e-8b5e2f749e1z',
    },
    name: { 
      doc: 'The name of the DRD.',
      profile: 'http://alps.io/schema.org/Text',
      sample: 'drdname',
      value: 'drdname',
    },
    status: {
      doc: 'How is the DRD.',
      profile: 'http://alps.io/schema.org/Text',
      sample: 'renegade',
      value: 'compliant',
    },
    old_status: {
      doc: 'How was the DRD before the last change',
      profile: 'http://alps.io/schema.org/Text',
      sample: 'renegade',
      value: 'compliant',
    },
    kind: {
      doc: 'What kind is it.',
      profile: 'http://alps.io/schema.org/Text',
      sample: 'standard',
      value: 'nonstandard',
    },
    size: {
      doc: 'How large it is',
      profile: 'http://alps.io/schema.org/Text',
      sample: 'medium',
      value: 'medium',
    },
    leviathan_uuid: {
      doc: 'The UUID of the creator Leviathan.',
      profile: 'http://alps.io/schema.org/Text',
      sample: '007d8e12-babd-4f2c-b01e-8b5e2f749e1b',
      value: '007d8e12-babd-b01e-4f2c-8b5e2f749e1b',
    },
    built_at: {
      doc: 'When the DRD was constructed.',
      profile: 'http://alps.io/schema.org/DateTime',
      sample: '2013-03-20T00:00:00+00:00',
      value: '2013-03-20T00:00:00+00:01',
    },
    leviathan: {
      doc: 'The associated Leviathan resource.',
      profile: 'http://alps.io/schema.org/Thing/Leviathan',
      sample: 'http://alps.io/schema.org/Thing/Leviathan',
      value: 'http://alps.io/schema.org/Thing/Leviathan',
    },
    location: {
      doc: 'The area the DRD is currently in',
      profile: 'http://alps.io/schema.org/Text',
      sample: 'moya',
      multiple: 'true',
      value: ['moya','japan'],
    },
    location_detail: {
      doc: 'Exactly where in the location the DRD currenlty is',
      profile: 'http://alps.io/schema.org/Text',
      sample: 'outside',
      value: 'inside',
    },
    leviathan_email: {
      doc: 'The Leviathan respond to email.',
      profile: 'http://alps.io/schema.org/Text',
      sample: 'joe@grumpycat.org',
      value: 'joe@grumpycat.org',
    },
    leviathan_uuid: {
      doc: 'The UUID of the creator Leviathan.',
      profile: 'http://alps.io/schema.org/Text',
      sample: '1234-5678-9abc-def1',
      value: '1234-9abc-5678-def1',
    },
    destroyed: {
      doc: 'This DRD has been destroyed',
      profile: 'http://alps.io/schema.org/Boolean',
      sample: 'destroyed',
      value: 'destroyed',
    },
    leviathan_health_points: {
      doc: 'The health points of Leviathan.',
      profile: 'http://alps.io/schema.org/Integer',
      value: 32,
    },
    term: {
      doc: 'The terms to search.',
      profile: 'http://alps.io/schema.org/Text',
      sample: 'searchterm',
      value: 'blunderbus',
    },
  },
  transitions: [
    {
      rel: 'self',
      doc: 'Shows a particular DRD.',
      profile: 'http://alps.io/schema.org/DRD', 
      href: 'www.example.com/drds/show/173875983789',
    },
    {
      rel: 'show',
      doc: 'Shows a particular DRD.',
      profile: 'http://alps.io/schema.org/DRD', 
      href: 'www.example.com/drds/show/173875983789',
    },
    {
      rel: 'leviathan-link',
      name: 'leviathan',
      doc: 'A reference to the Leviathan the DRD works on.',
      embed: true, 
      profile: 'http://alps.io/schema.org/Leviathan#leviathan',
      href: 'http://example.com/drds/Leviathan',
    },
    {
      rel: 'repair-history',
      doc: 'A reference to the list of historical repairs performed.',
      embed: true,
      profile: 'http://alps.io/schema.org/Repairs#history',
      href: 'http://example.com/drds/Repairs',
    },
    {
      rel: 'activate',
      doc: 'Activates a DRD if it is deactivated.',
      profile: 'http://alps.io/schema.org/DRD',
      href: 'http://example.com/drds/activate/173875983789',
      method: 'PUT',
    },
    {
      rel: 'deactivate',
      doc: 'Deactivates a DRD if it is activated.',
      profile: 'http://alps.io/schema.org/DRD',
      href: 'http://example.com/drds/show/173875983789',
      method: 'PUT',
    },
    {
      rel: 'delete',
      doc: 'Drops a DRD out an air-lock.',
      href: 'http://example.com/drds/show/173875983789',
      method: 'DELETE',
    },
    {
      rel: 'update',
      doc: 'Updates a DRD.',
      profile: 'http://alps.io/schema.org/DRDs#update',
      href: 'http://example.com/drds/show/173875983789',
      method: 'PUT',
      descriptors: {
        links: {
          self: 'http://alps.io/schema.org/DRDs#update',
          help: 'help.example.com/Forms/update',
        },
        status: {
          doc: 'How is the DRD.', 
          profile: 'http://alps.io/schema.org/Text',
          sample: 'renegade',
          value: 'renegade',
          type: 'text',
          data_type: 'select',
          validators: [
            :required,
          ],
          options: { 
            'id' => 'drd_status_options',
            'hash' => {
              'active' => 'activated',
              'inactive' => 'deactivated',
              'unknown' => 'renegade',
              },
          },
        },
        old_status: {
          doc: 'How was the DRD before the last change',
          profile: 'http://alps.io/schema.org/Text',
          sample: 'renegade',
          type: 'text',
          data_type: 'select',
          validators: [
            :required,
          ],
          options: {
            'id' => 'drd_status_options',
            'hash' => {
              'active' => 'activated',
              'inactive' => 'deactivated',
              'unknow' => 'renegade',
            },        
          },
        },
        kind: {
          doc: 'What kind is it.',
          profile: 'http://alps.io/schema.org/Text',
          sample: 'standard',
          type: 'text',
          data_type: 'select',
          options: {
            'list' => [
              'standard',
              'sentinel',
            ]
          },
        },
        size: {
          doc: 'How large it is',
          profile: 'http://alps.io/schema.org/Text',
          sample: 'medium',
          type: 'text',
          data_type: 'text',
          options: {
            'list' => [
             'big',
             'small',
            ],
          },
        },
        location: {
          doc: 'The area the DRD is currently in',
          profile: 'http://alps.io/schema.org/Text',
          sample: 'moya',
          multiple: 'true',
          field_type: 'select',
          options: {
            'external' => {
              'source' => 'http://crichton.example.com/drd_location_detail_list#items',
            },
          },
        },
        location_detail: {
          doc: 'Exactly where in the location the DRD currenlty is',
          profile: 'http://alps.io/schema.org/Text',
          sample: 'outside',
          field_type: 'select',
          options: {
            'external' => {
              'source' => 'http://crichton.example.com/drd_location_detail_list#items',
              'target' => 'location_detail_id',
              'prompt' => 'location_detail_text',
            },
          },
        },
        destroyed: {
          doc: 'This DRD has been destroyed',
          profile: 'http://alps.io/schema.org/Boolean',
          sample: true,
          type: 'boolean',
          field_type: 'boolean',
        },
      },
    },
  ],
}
end
