# frozen_string_literal: true

require "test_helper"
require "rexml/document"

class TestTimbre < Minitest::Test
  def test_attributes
    cfdi = Cfdi40.open(File.read('test/files/cfdi_timbrado.xml'))
    timbre = cfdi.timbre
    assert_equal "8E5C7749-7E57-4EC6-9EBD-7971F875DF0A", timbre.uuid
    assert_equal "00001000000712749552", timbre.no_certificado_sat
    assert_equal Time.new(2025, 8, 24, 9, 56, 42), timbre.fecha_timbrado
    assert_equal 'ISI980812XYZ', timbre.rfc_prov_certif
    assert_equal 'TzSbxIL4jMIrbdrAJEplFJGof3enctptP97KRB8hXvP26P8ncHb3vME0fipzl6yHJASv/kp9xHQ7u70eNWMRrdqH' \
                 'TxKwlH9gwEy1+96+zavFiAosSkmqYOXrhrxZcmKRBDH5OK6QBlFO0paSNe/78ut4OECP2rtFYaTNldZd9un973wr' \
                 'KFUce9WLqQtdtZha50EzudAQckBLvtsBYpJTt0ux+/bc7RkEzcv63eu/hOQnMLtX+jzmSELmD/8h+sqm1+KVfRQh' \
                 '9Vn3icWOkquNCn4CEQSOeE5rReL9k5o36PJVNrP7A8qCa/kwxuizHge+Wx91kkdvIzh+k0Qv3dvBsA==',
                 timbre.sello_sat
    assert_equal 'ioCje8VOdHUNqqfkLdeKp92Blzutfjlcs+i3IsU33DS/CeR3ZyQQY0RwrNR/x2m/aag4ic4cIpad/3eYkG4p+quV' \
                 'lhi5UmnRit3OxauP9w7i6xMJPZ9rREpQwgIQId8NNiOC+tII2c7ZO6ljrTYhpC4CHinnl3zdkzB+e79jpNS/aiZ0' \
                 'RjGuLPuN2joOd5L7tmi6NQyb8zOKcYKTPbIJNKFexWmWIBbs0/RTOgh6NjDMvd7STjNbRnSixJ2f5XgfArnwBJ19' \
                 'CC9fsdSGCzQt+lBbGvN5Bzx1LdoGCrePwrJvn34J8IT2CcQdAY/OuClpPervwrz3LwF7XsKb3Ob9J3w==',
                 timbre.sello_cfd
    assert_equal '1.1', timbre.version
  end
end
