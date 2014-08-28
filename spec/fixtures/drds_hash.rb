module ComplexRepresentor
DRDS_HASH = {
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
      href: 'http://example.com/drds', # Crichton needs to give the actual link
      method: 'GET', # When it's in Descriptor 'links' or 'safe' section
    },
    {
      rel: 'list',
      doc: 'Returns a list of DRDs.', # Same as descriptor file
      rt: 'drds', # This should actually be a link right? #Profile?
      href: 'http://example.com/drds/list',
    },
    {
      rel: 'search',
      doc: 'Returns a list of DRDs that satisfy the search term.',
      href: 'http://example.com/drds/search',
      rt: 'drds',
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
      method: 'POST',
      descriptors: { 
        name: { #These should only show up under 'name' if they actually show up in the document body
          doc: 'The name of the DRD.',
          profile: 'http://alps.io/schema.org/Text',
          sample: 'drdname',
          field_type: 'text', #
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
              field_type: 'text', #not actually supported
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
  #embedded: { itemd: [ See: single_drd.rb ] }  
}
end
    