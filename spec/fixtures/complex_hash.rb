module ComplexRepresentor
COMPLEX_REPRESENTOR = {
  protocol: 'http', # The protocol we're using
  href: 'www.example.com/drds', # Crichton needs to say where we are
  id: 'DRDs', # ID from desrciptor
  doc: 'Describes the semantics, states and state transitions associated with DRDs.', # Doc from descriptor
  links: {
    self: 'www.example.com/drds/show/DRDs',
    help: 'http://alps.io/schema.org/DRDs'
  },
  attributes: { #Data, also Semantics, Should probably rename to Data
    total_count: { #semantic key
      doc: 'The total count of DRDs.', # Descriptor semantic doc
      type: 'semantic', # Descriptor semantic type
      profile: 'http://alps.io/schema.org/Integer', # same as 'href' in Descriptor file
      sample: 1, # same as sample in descriptor
      value: 2, # value from service interating crichton
    },
  },
  transitions: [
    {
      rel: 'self', # same as Descriptor File
      href: 'www.example.com/drds', # Crichton needs to give the actual link
      type: 'safe', # When it's in Descriptor 'links' or 'safe' section
    },
    {
      rel: 'list',
      doc: 'Returns a list of DRDs.', # Same as descriptor file
      rt: 'drds', # This should actually be a link right? #Profile?
      href: 'www.example.com/drds/list',
      type: 'safe',
    },
    {
      rel: 'search',
      doc: 'Returns a list of DRDs that satisfy the search term.',
      href: 'www.example.com/drds/search',
      rt: 'drds',
      type: 'safe',
      descriptors: {# parameters - This should probably be change is representors to just be "data"
        search_term: {
          doc: 'The terms to search.',
          profile: 'http://alps.io/schema.org/Text',
          sample: 'searchterm',
          multiple: true,
          scope: 'href',
        },
        name: { #These should only show up under 'name' if they actually show up in the document body
          doc: 'The name of the DRD.',
          profile: 'http://alps.io/schema.org/Text',
          sample: 'drdname',
          value: 'drdname',
          scope: 'href',
          field_type: 'text', # I'm not sure representors is supporting this, but it should
        },
      },
    },        
    {
      rel: 'create',
      doc: 'Creates a DRD.',
      rt: 'drd',
      links: {
        self: 'http://alps.io/schema.org/DRDs#update',
        help: 'help.example.com/Forms/update',
      },
      href: 'www.example.com/drds/create',
      type: 'unsafe',
      descriptors: { 
        name: { #These should only show up under 'name' if they actually show up in the document body
          doc: 'The name of the DRD.',
          profile: 'http://alps.io/schema.org/Text',
          sample: 'drdname',
          field_type: 'text',
          validators: [
            'required',
            {maxlength: 50},
          ],
        },
        leviathan: {
          doc: 'The associated Leviathan resource.',
          profile: 'http://alps.io/schema.org/Thing/Leviathan',
          #embed: 'single-optional'
          sample: 'http://alps.io/schema.org/Thing/Leviathan',
          value: 'http://alps.io/schema.org/Thing/Leviathan',
          type: 'object', #not yet supported in Representors
          descriptors: {
            leviathan_uuid: {
              doc: 'The UUID of the creator Leviathan.',
              profile: 'http://alps.io/schema.org/Text',
              sample: '007d8e12-babd-4f2c-b01e-8b5e2f749e1b',
              type: 'text',
              field_type: 'text',
            },
            leviathan_health_points: {
              doc: 'The health points of Leviathan.',
              profile: 'http://alps.io/schema.org/Integer',
              type: 'integer',
              field_type: 'number',
              validators: [
                'required',
                {min: 0},
                {max: 100},
              ],
              sample: 42,
            },
            leviathan_email: {
              doc: 'The Leviathan respond to email.',
              profile: 'http://alps.io/schema.org/Text',
              sample: 'joe@grumpycat.org',
              type: 'text',
              field_type: 'email',
              validators: [
                'required',
                {pattern: "^.+@.+$"}
              ]
            },
          },
        },
      },
    },
  ],
    
    
  embedded: {
    items: [ # rel for the embedded item
      {
        protocol: 'http', # The protocol we're using
        href: 'www.example.com/drd/1', # Crichton needs to say where we are
        id: 'DRD',
        doc: 'Diagnostic Repair Drones or DRDs are small robots that move around Leviathans. They are built by a Leviathan as it grows.',
        attributes: { #need to rename to data
          uuid: {
            doc: 'The UUID of the DRD.',
            profile: 'http://alps.io/schema.org/Text',
            sample: '007d8e12-babd-4f2c-b01e-8b5e2f749e1z',
            value: '007d8e12-babd-4f2c-b01e-8b5e2f749e1z',
          },
          name: { #These should only show up under 'name' if they actually show up in the document body
            doc: 'The name of the DRD.',
            profile: 'http://alps.io/schema.org/Text',
            sample: 'drdname',
            value: 'drdname',
          },
          status: {
            doc: 'How is the DRD.',
            profile: 'http://alps.io/schema.org/Text',
            sample: 'renegade',
            value: 'renegade',
          },
          old_status: {
            doc: 'How was the DRD before the last change',
            profile: 'http://alps.io/schema.org/Text',
            sample: 'renegade',
            value: 'renegade',
          },
          kind: {
            doc: 'What kind is it.',
            profile: 'http://alps.io/schema.org/Text',
            sample: 'standard',
            value: 'standard',
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
            value: '007d8e12-babd-4f2c-b01e-8b5e2f749e1b',
          },
          built_at: {
            doc: 'When the DRD was constructed.',
            profile: 'http://alps.io/schema.org/DateTime',
            sample: '2013-03-20T00:00:00+00:00',
            value: '2013-03-20T00:00:00+00:00',
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
            value: 'moya',
          },
          location_detail: {
            doc: 'Exactly where in the location the DRD currenlty is',
            profile: 'http://alps.io/schema.org/Text',
            sample: 'outside',
            value: 'outside',
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
            value: '1234-5678-9abc-def1',
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
            value: 'searchterm',
          },
        },
        transitions: [
          {
            rel: 'show',
            doc: 'Shows a particular DRD.',
            rt: 'drd',
            href: 'www.example.com/drds/show/173875983789',
            type: 'safe',
          },
          {
            rel: 'leviathan-link',
            name: 'leviathan', # I'm not sure representors is supporting this, but it should
            doc: 'A reference to the Leviathan the DRD works on.',
            embed: true, #?
            rt: 'http://alps.io/schema.org/Leviathan#leviathan',
            href: 'www.example.com/drds/Leviathan',
            type: 'safe',
          },
          {
            rel: 'repair-history',
            doc: 'A reference to the list of historical repairs performed.',
            embed: true, #?,
            rt: 'http://alps.io/schema.org/Repairs#history',
            href: 'www.example.com/drds/Repairs',
            type: 'safe',
          },
          {
            rel: 'activate',
            doc: 'Activates a DRD if it is deactivated.',
            rt: 'drd',
            href: 'www.example.com/drds/activate/173875983789',
            type: 'idempotent',
          },
          {
            rel: 'deactivate',
            doc: 'Deactivates a DRD if it is activated.',
            rt: 'drd',
            href: 'www.example.com/drds/show/173875983789',
            type: 'idempotent',
          },
          {
            rel: 'delete',
            doc: 'Drops a DRD out an air-lock.',
            rt: 'none', # nil?  maybe don't even show it?
            href: 'www.example.com/drds/show/173875983789',
            type: 'idempotent',
          },
          {
            rel: 'update',
            doc: 'Updates a DRD.',
            rt: 'none',
            profile: 'http://alps.io/schema.org/DRDs#update',#from links->self
            href: 'www.example.com/drds/show/173875983789',
            type: 'idempotent',
            descriptors: {# from data - should probably just be called data
              links: {
                self: 'http://alps.io/schema.org/DRDs#update',
                help: 'help.example.com/Forms/update',
              },
              status: {
                doc: 'How is the DRD.', # Description also exists, but I don't know why... bug?
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
                sample: 'destroyed',
                type: 'boolean',
                field_type: 'boolean',
              },
            },
          },
        ],
      },
    ],
  },
}
end
    