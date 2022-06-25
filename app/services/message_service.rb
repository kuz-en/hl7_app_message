class MessageService
  Patient = Struct.new(:firstname, :middlename, :lastname, :birth_date, :sex, keyword_init: true)
  Request = Struct.new(:uid, :scheduled_at, :service_abbr, :dicom_id, :dicom_uid, keyword_init: true)
  Technician = Struct.new(:firstname, :middlename, :lastname, keyword_init: true)

  def initialize(patient = Patient.new(firstname: 'Александр',
                                       middlename: 'Михайлович',
                                       lastname: 'Тулузаков',
                                       birth_date: Date.new(1950, 1, 21),
                                       sex: 'm'),

                 request = Request.new(uid: '85792_smol',
                                       scheduled_at: DateTime.new(2019, 6, 21, 16, 5, 0),
                                       service_abbr: 'L-spine',
                                       dicom_id: 'SMK00445657_1',
                                       dicom_uid: '1.3.12.2.1107.5.2.6.24133.69992.2019062145261830715'),

                 technician = Technician.new(firstname: 'Людмила',
                                             middlename: 'Викторовна',
                                             lastname: 'Щербакова'))

    @patient = patient
    @request = request
    @technician = technician

  end



end
