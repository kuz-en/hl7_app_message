require 'rails_helper'

MESSAGE = "MSH|^~\\&||MRTEXPERT|||||ORM^O01||P|2.3|||||||\r\n" \
  "PID|||85792_smol^^^&MIAS||TULUZAKOV AM||19500121|M||0||||||\r\n" \
  "ORC|NW||||||^^^201906211605||||||\r\n" \
  "OBR||||^^^^L-spine||||||||||||||Scherbakova|SMK00445657_1|Scherbakova||||MR||||||||||True&Scherbakova Lyudmila Viktorovna|||||||||\r\n" \
  "ZDS|1.3.12.2.1107.5.2.6.24133.69992.2019062145261830715|MRSI24133|MRSI24133\r\n" \
  "PV1||||||||True^|True^".freeze


Patient = Struct.new(:firstname, :middlename, :lastname, :birth_date, :sex, keyword_init: true)
Request = Struct.new(:uid, :scheduled_at, :service_abbr, :dicom_id, :dicom_uid, keyword_init: true)
Technician = Struct.new(:firstname, :middlename, :lastname, keyword_init: true)

PATIENT = Patient.new(firstname: 'Александр',
                      middlename: 'Михайлович',
                      lastname: 'Тулузаков',
                      birth_date: Date.new(1950, 1, 21),
                      sex: 'm')

REQUEST = Request.new(uid: '85792_smol',
                      scheduled_at: DateTime.new(2019, 6, 21, 16, 5, 0),
                      service_abbr: 'L-spine',
                      dicom_id: 'SMK00445657_1',
                      dicom_uid: '1.3.12.2.1107.5.2.6.24133.69992.2019062145261830715')

TECHNICIAN = Technician.new(firstname: 'Людмила',
                            middlename: 'Викторовна',
                            lastname: 'Щербакова')

m = MessageService.new(PATIENT, REQUEST, TECHNICIAN)

RSpec.describe MessageService, type: :services do
  it '#translit_name' do
    m.send(:translit_name, TECHNICIAN)

    expect(TECHNICIAN.lastname).to match 'Scherbakova'
  end

  it '#create_message' do
    m.send(:translit_name, TECHNICIAN)
    m.send(:translit_name, PATIENT)

    m.send(:create_message)
    expect(m.instance_variable_get(:@message).to_hl7).to eq MESSAGE
  end
end
