
#include "AoiTrigger.h"
#include <iomanip>
AoiTrigger::AoiTrigger(float x, float z, float speed, float range, AoiContext* context) :Aoi(x, z, speed, context) {
	
	
	m_range = range;
	//printf("the init range = %d,%f\n", m_range,range);
}


AoiTrigger::~AoiTrigger() {
}

void AoiTrigger::Enter() {

	//printf("the range = %d\n", m_range);
	//printf("entity enter m_id = %d\n", m_id);
	m_trigger = create_trigger(m_context->m_context, m_id, m_pos.m_x, m_pos.m_z, m_range, AoiContext::OnTriggerEnter, m_context);
	
	removeID = m_id;
}
void AoiTrigger::refresh() {

	move_trigger(m_context->m_context, m_trigger, m_pos.m_x, m_pos.m_z, AoiContext::OnTriggerEnter, m_context, AoiContext::OnTriggerLeave, m_context);

}
void AoiTrigger::Draw() {
}
